package com.magizh.calendar.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * OpenAPI/Swagger configuration for API documentation
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI magizhCalendarOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Magizh Calendar API")
                        .description("""
                                Tamil Panchangam Calendar API providing daily and weekly panchangam data.

                                ## Features
                                - **Five Angams**: Nakshatram, Thithi, Yogam, Karanam, Vaaram
                                - **Timings**: Sunrise, Sunset, Nalla Neram, Rahukaalam, Yamagandam
                                - **Food Status**: Smart dietary guidance based on auspicious days
                                - **Location-aware**: Calculations based on latitude/longitude

                                ## Tamil Calendar Concepts
                                - **Nakshatram**: Lunar mansion (27 stars)
                                - **Thithi**: Lunar day (30 per month)
                                - **Yogam**: Sun-Moon combination (27 yogams)
                                - **Karanam**: Half of thithi (60 per month)
                                - **Vaaram**: Day of week
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Magizh Calendar Team")
                                .email("support@magizh.com"))
                        .license(new License()
                                .name("Private")
                                .url("https://magizh.com")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080")
                                .description("Local Development Server")
                ));
    }
}
