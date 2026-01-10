package com.magizh.calendar.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * CORS configuration for the API.
 * Restricts access to known origins only (iOS apps don't need CORS,
 * this is for future web clients).
 */
@Configuration
public class CorsConfig {

    @Value("${api.cors.allowed-origins:*}")
    private String allowedOrigins;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Parse comma-separated origins
        if ("*".equals(allowedOrigins)) {
            configuration.setAllowedOriginPatterns(List.of("*"));
        } else {
            List<String> origins = Arrays.asList(allowedOrigins.split(","));
            configuration.setAllowedOrigins(origins.stream().map(String::trim).toList());
        }

        // Allowed HTTP methods
        configuration.setAllowedMethods(List.of("GET", "POST", "OPTIONS"));

        // Allowed headers (including our custom auth headers)
        configuration.setAllowedHeaders(List.of(
            "X-API-Key",
            "X-Client-Type",
            "Content-Type",
            "Accept",
            "Origin"
        ));

        // Exposed headers (client can read these)
        configuration.setExposedHeaders(List.of(
            "X-Rate-Limit-Remaining",
            "Retry-After"
        ));

        // Don't allow credentials (we use API key, not cookies)
        configuration.setAllowCredentials(false);

        // Cache preflight response for 1 hour
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
