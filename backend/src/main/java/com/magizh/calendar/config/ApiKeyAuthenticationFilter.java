package com.magizh.calendar.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Set;

/**
 * Filter that validates API keys in the X-API-Key header.
 * Supports multiple keys for different clients (iOS, Web, Dev).
 */
@Component
public class ApiKeyAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(ApiKeyAuthenticationFilter.class);

    private static final String API_KEY_HEADER = "X-API-Key";
    private static final String CLIENT_TYPE_HEADER = "X-Client-Type";

    @Value("${api.security.keys.ios:}")
    private String iosApiKey;

    @Value("${api.security.keys.web:}")
    private String webApiKey;

    @Value("${api.security.keys.dev:}")
    private String devApiKey;

    @Value("${api.security.enabled:true}")
    private boolean securityEnabled;

    // Endpoints that don't require authentication
    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/api/panchangam/health",
        "/actuator/health",
        "/actuator/info",
        "/swagger-ui",
        "/v3/api-docs",
        "/error"
    );

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String path = request.getRequestURI();

        // Skip auth for public paths
        if (isPublicPath(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Skip auth if security is disabled (for local dev)
        if (!securityEnabled) {
            setAuthentication("dev-user", "ROLE_DEV");
            filterChain.doFilter(request, response);
            return;
        }

        String apiKey = request.getHeader(API_KEY_HEADER);
        String clientType = request.getHeader(CLIENT_TYPE_HEADER);

        if (apiKey == null || apiKey.isBlank()) {
            log.warn("Missing API key for request: {} {}", request.getMethod(), path);
            sendError(response, HttpStatus.UNAUTHORIZED, "Missing API key");
            return;
        }

        // Validate API key and determine client type
        String role = validateApiKey(apiKey, clientType);
        if (role == null) {
            log.warn("Invalid API key for request: {} {}", request.getMethod(), path);
            sendError(response, HttpStatus.UNAUTHORIZED, "Invalid API key");
            return;
        }

        log.debug("Authenticated request from {} client: {} {}",
            clientType != null ? clientType : "unknown", request.getMethod(), path);

        setAuthentication(clientType != null ? clientType : "unknown", role);
        filterChain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        return PUBLIC_PATHS.stream().anyMatch(path::startsWith);
    }

    private String validateApiKey(String apiKey, String clientType) {
        // Check iOS key
        if (iosApiKey != null && !iosApiKey.isBlank() && apiKey.equals(iosApiKey)) {
            return "ROLE_IOS_CLIENT";
        }
        // Check web key
        if (webApiKey != null && !webApiKey.isBlank() && apiKey.equals(webApiKey)) {
            return "ROLE_WEB_CLIENT";
        }
        // Check dev key (for development/testing)
        if (devApiKey != null && !devApiKey.isBlank() && apiKey.equals(devApiKey)) {
            return "ROLE_DEV";
        }
        return null;
    }

    private void setAuthentication(String principal, String role) {
        var authorities = List.of(new SimpleGrantedAuthority(role));
        var auth = new UsernamePasswordAuthenticationToken(principal, null, authorities);
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    private void sendError(HttpServletResponse response, HttpStatus status, String message)
            throws IOException {
        response.setStatus(status.value());
        response.setContentType("application/problem+json");
        response.getWriter().write("""
            {
                "type": "https://api.magizh.com/errors/authentication",
                "title": "Authentication Error",
                "status": %d,
                "detail": "%s"
            }
            """.formatted(status.value(), message));
    }
}
