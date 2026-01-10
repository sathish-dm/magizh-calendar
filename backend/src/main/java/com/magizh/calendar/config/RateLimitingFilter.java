package com.magizh.calendar.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Simple in-memory rate limiting filter.
 * Limits requests per minute per client (identified by API key or IP).
 *
 * Note: For horizontal scaling, replace with Redis-based rate limiting.
 */
@Component
@Order(1) // Run before authentication filter
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RateLimitingFilter.class);

    @Value("${api.ratelimit.requests-per-minute:60}")
    private int requestsPerMinute;

    @Value("${api.ratelimit.enabled:true}")
    private boolean rateLimitEnabled;

    // Simple in-memory rate limiting (use Redis for production scaling)
    private final Map<String, RateLimitBucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        if (!rateLimitEnabled) {
            filterChain.doFilter(request, response);
            return;
        }

        // Skip rate limiting for health checks
        String path = request.getRequestURI();
        if (path.contains("/health") || path.contains("/actuator")) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientId = getClientIdentifier(request);
        RateLimitBucket bucket = buckets.computeIfAbsent(
            clientId,
            k -> new RateLimitBucket(requestsPerMinute)
        );

        if (!bucket.tryConsume()) {
            log.warn("Rate limit exceeded for client: {}", clientId);
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setHeader("Retry-After", "60");
            response.setHeader("X-Rate-Limit-Remaining", "0");
            response.setContentType("application/problem+json");
            response.getWriter().write("""
                {
                    "type": "https://api.magizh.com/errors/rate-limit",
                    "title": "Rate Limit Exceeded",
                    "status": 429,
                    "detail": "Too many requests. Please wait before retrying."
                }
                """);
            return;
        }

        response.setHeader("X-Rate-Limit-Remaining",
            String.valueOf(bucket.getRemaining()));
        filterChain.doFilter(request, response);
    }

    private String getClientIdentifier(HttpServletRequest request) {
        // Prefer API key, fallback to IP
        String apiKey = request.getHeader("X-API-Key");
        if (apiKey != null && !apiKey.isBlank()) {
            // Hash the API key for privacy in logs
            return "key:" + Math.abs(apiKey.hashCode());
        }

        // Use IP address as fallback
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return "ip:" + forwardedFor.split(",")[0].trim();
        }
        return "ip:" + request.getRemoteAddr();
    }

    /**
     * Simple sliding window rate limit bucket.
     * Resets counter every minute.
     */
    private static class RateLimitBucket {
        private final int maxRequests;
        private final AtomicInteger count = new AtomicInteger(0);
        private volatile long windowStart = System.currentTimeMillis();

        RateLimitBucket(int maxRequests) {
            this.maxRequests = maxRequests;
        }

        synchronized boolean tryConsume() {
            long now = System.currentTimeMillis();
            // Reset counter if window has passed (1 minute)
            if (now - windowStart > 60_000) {
                windowStart = now;
                count.set(0);
            }
            return count.incrementAndGet() <= maxRequests;
        }

        int getRemaining() {
            return Math.max(0, maxRequests - count.get());
        }
    }
}
