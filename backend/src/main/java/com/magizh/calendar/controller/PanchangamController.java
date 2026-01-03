package com.magizh.calendar.controller;

import com.magizh.calendar.model.PanchangamResponse;
import com.magizh.calendar.service.PanchangamService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * REST Controller for Panchangam API endpoints
 */
@RestController
@RequestMapping("/api/panchangam")
@Validated
@CrossOrigin(origins = "*")
@Tag(name = "Panchangam", description = "Tamil Panchangam Calendar API")
public class PanchangamController {

    private final PanchangamService panchangamService;

    public PanchangamController(PanchangamService panchangamService) {
        this.panchangamService = panchangamService;
    }

    @Operation(
            summary = "Get daily Panchangam",
            description = "Returns complete Panchangam data for a specific date and location, including all five angams (Nakshatram, Thithi, Yogam, Karanam, Vaaram), timings, and food status."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved Panchangam data",
                    content = @Content(schema = @Schema(implementation = PanchangamResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid date format or parameters")
    })
    @GetMapping("/daily")
    public ResponseEntity<PanchangamResponse> getDaily(
            @Parameter(description = "Date in YYYY-MM-DD format", example = "2026-01-03", required = true)
            @RequestParam @NotNull LocalDate date,

            @Parameter(description = "Latitude of location", example = "13.0827")
            @RequestParam(defaultValue = "13.0827") double lat,

            @Parameter(description = "Longitude of location", example = "80.2707")
            @RequestParam(defaultValue = "80.2707") double lng,

            @Parameter(description = "Timezone identifier", example = "Asia/Kolkata")
            @RequestParam(defaultValue = "Asia/Kolkata") String timezone
    ) {
        var response = panchangamService.getDailyPanchangam(date, lat, lng, timezone);
        return ResponseEntity.ok(response);
    }

    @Operation(
            summary = "Get weekly Panchangam",
            description = "Returns Panchangam data for 7 consecutive days starting from the specified date."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved weekly Panchangam data"),
            @ApiResponse(responseCode = "400", description = "Invalid date format or parameters")
    })
    @GetMapping("/weekly")
    public ResponseEntity<List<PanchangamResponse>> getWeekly(
            @Parameter(description = "Start date in YYYY-MM-DD format", example = "2026-01-03", required = true)
            @RequestParam @NotNull LocalDate startDate,

            @Parameter(description = "Latitude of location", example = "13.0827")
            @RequestParam(defaultValue = "13.0827") double lat,

            @Parameter(description = "Longitude of location", example = "80.2707")
            @RequestParam(defaultValue = "80.2707") double lng,

            @Parameter(description = "Timezone identifier", example = "Asia/Kolkata")
            @RequestParam(defaultValue = "Asia/Kolkata") String timezone
    ) {
        var response = panchangamService.getWeeklyPanchangam(startDate, lat, lng, timezone);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Health check", description = "Returns OK if the API is running")
    @ApiResponse(responseCode = "200", description = "API is healthy")
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
