package com.magizh.calendar.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Request logging configuration for debugging and monitoring
 */
@Configuration
public class RequestLoggingConfig {

    @Bean
    public RequestLoggingFilter requestLoggingFilter() {
        return new RequestLoggingFilter();
    }

    public static class RequestLoggingFilter extends OncePerRequestFilter {

        private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

        @Override
        protected void doFilterInternal(
                HttpServletRequest request,
                HttpServletResponse response,
                FilterChain filterChain
        ) throws ServletException, IOException {

            long startTime = System.currentTimeMillis();

            // Skip logging for static resources and actuator
            String path = request.getRequestURI();
            if (shouldSkipLogging(path)) {
                filterChain.doFilter(request, response);
                return;
            }

            try {
                filterChain.doFilter(request, response);
            } finally {
                long duration = System.currentTimeMillis() - startTime;

                log.info("{} {} {} - {}ms",
                        request.getMethod(),
                        getFullPath(request),
                        response.getStatus(),
                        duration
                );

                // Warn on slow requests
                if (duration > 1000) {
                    log.warn("Slow request: {} {} took {}ms",
                            request.getMethod(),
                            path,
                            duration
                    );
                }
            }
        }

        private boolean shouldSkipLogging(String path) {
            return path.startsWith("/actuator") ||
                   path.startsWith("/swagger") ||
                   path.startsWith("/v3/api-docs") ||
                   path.startsWith("/webjars") ||
                   path.endsWith(".css") ||
                   path.endsWith(".js") ||
                   path.endsWith(".ico");
        }

        private String getFullPath(HttpServletRequest request) {
            String queryString = request.getQueryString();
            if (queryString != null) {
                return request.getRequestURI() + "?" + queryString;
            }
            return request.getRequestURI();
        }
    }
}
