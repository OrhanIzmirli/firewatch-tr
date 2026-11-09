# Frontend integration contracts (proposal)

These are proposed contracts for backend review, not claims that endpoints exist.
Base: origin/main 4e0e402, version 1.0.3+4. Frontend build: 1.0.4+5.
Each frontend branch is stacked on the preceding item: F → A → E → D → B → C.
Do not merge before emulator review.

## Risk summary (existing GET /api/risk/summary)

Keep `data[]` with `region`, `general_risk_score`, `temperature`, `humidity`,
`wind_speed`, `dryness_index`, `vegetation_density`, `date`, and optional
`previous_risk_score`. Add optional integer `nearby_fire_count`.
Specify the count's radius and time window before production wording is finalized.
Missing counts mean unavailable, never zero.

Display thresholds retain the published app's national thresholds:
0–24 Low (green), 25–49 Medium (yellow), 50–74 High (orange), 75–100
Critical / “Çok yüksek” (red). Backend `risk_level` is not used to override
the numeric score. These are index bands, not probability percentages.
Backend owners should confirm these shared display thresholds.

## District risk GeoJSON

Configure `--dart-define=DISTRICT_RISK_URL=https://…` with the approved endpoint.
Without it, the screen uses conspicuously labeled, schematic sample polygons.
The sample polygons are NOT administrative boundaries and are not suitable for decisions.

Return a GeoJSON FeatureCollection with Polygon or MultiPolygon features.
Coordinates use WGS84 [longitude, latitude]; preserve interior holes and islands.
Provide simplified geometry, a stable feature `id`, and properties:

```json
{"city":"İzmir","district":"…","risk_score":62,"calculated_at":"2026-10-24T09:00:00Z"}
```

Use null for an unavailable score. Do not replace missing scores with zero.
City selection fits the union of available district geometries; district selection
fits all islands. No historical slider is included in this first version.

## History GeoJSON

Configure `--dart-define=FIRE_HISTORY_URL=https://firewatch-tr-backend.onrender.com/api/history`
(implemented by backend 6401434 / 8d7553b; live since 2026-11-06).
GET query: `from` and `to` as plain calendar days, `YYYY-MM-DD` (not timestamps; a
timestamp is rejected with 400). Days are Europe/Istanbul and the ending day is inclusive.
At most 1,100 days per request, enough for the "since last summer" and "last 3 years" presets.
Return a FeatureCollection with stable ids and Polygon/MultiPolygon boundaries.
Feature `id` is a number from the backend; the app also accepts text ids (sample data).

### What the backend actually returns (NASA FIRMS satellite records)

The first source is the backend's own `fire_incidents` table: VIIRS/MODIS thermal
detections clustered into incidents, ≥5 detections, fixed heat sources excluded.
There is data from 2026-08-05 onward (`metadata.data_available_from`).

```json
{
  "city":"Antalya", "district":"Kepez", "district_basis":"nearest_district_center",
  "date_start":"2026-09-07", "date_end":"2026-09-09",
  "area_ha":null, "detection_count":533, "duration_hours":41.1, "max_frp_mw":3422.3,
  "geometry_kind":"satellite_heat_detection_footprint",
  "source":"NASA FIRMS", "source_url":"https://firms.modaps.eosdis.nasa.gov/map/",
  "centroid":[30.78444, 37.10792],
  "restoration_updates":[], "campaigns":[]
}
```

* The geometry is the **satellite heat-detection footprint** (188 m around each detection,
  merged and simplified), not a burn scar. The app says so in the detail sheet.
* `area_ha` is always `null`: no burned area is measured. The app shows detections,
  duration and peak FRP instead, and never a football-pitch comparison for these records.
* `district` is the district with the nearest centre (`district_basis`); the app notes this.
* `metadata.source` carries provider, products, caveats and the FIRMS acknowledgement;
  the app shows the same acknowledgement sentence under the record.
* `restoration_updates` and `campaigns` are empty until verified official records exist.

### Full schema (future sources with official records)

Each feature's properties:

```json
{
  "city":"…", "district":"…", "date_start":"2026-07-10",
  "date_end":"2026-07-13", "area_ha":2000,
  "source_url":"https://official-source.example/record",
  "restoration_updates":[{
    "date":"2026-10-01", "institution":"…", "work":"…",
    "restored_ha":250, "source_url":"https://official-source.example/announcement"
  }],
  "campaigns":[{
    "title":"…", "url":"https://institution.example/campaign", "official_source":true
  }]
}
```

The `.example` URLs above are schema placeholders, not actual evidence or links to publish.
`restored_ha` is cumulative as of that update; updates are not summed together.
Optional `cost_amount` and `cost_currency` require the update's official source.
Optional `cost_comparison` additionally requires `comparison_source_url`, supporting
the comparison's unit cost, date, currency and calculation. Never invent cost comparisons.
Records without source URLs are not rendered as verified restoration progress.
Attribution: NASA FIRMS (VIIRS/MODIS), with NASA's acknowledgement sentence
(verbatim from earthdata.nasa.gov/data/tools/firms, checked 2026-11-06). EFFIS is not used
for history; if a burnt-area product is added later, verify its licence then.
Fixture mode explicitly attributes only sample data.
Football comparison: area_ha / 0.714, rounded to whole pitches — only when `area_ha` is a
measured number; never for satellite heat-detection records.

## News (existing GET /api/news)

New optional query `content_type`: recovery, solidarity, events.
Existing fire requests omit it for backward compatibility.
Keep pagination with `limit` / `offset`. Response keeps `data[]`.
New optional fields survive offline caching:

* `content_type`: fires (legacy default), recovery, solidarity, events
* `image_url`, `source_logo_url`: HTTPS media
* `official_source`: true only after editorial verification
* `action_url`: institution-owned participation/donation page
* `event_start`, `event_end`: ISO timestamps including timezone
* `event_city`, `event_location`

Always keep `source_url`. Donation amounts and event claims must be taken from
the institution's own announcement. `official_source` is an editorial assertion,
not a frontend authenticity check; the backend must verify action and source URLs.
Calendar actions open the system calendar confirmation UI, without silently adding events.
The frontend uses add_2_calendar 3.0.1 because 3.1.1 fails against this project's Kotlin build.

## CARTO

Supply `--dart-define=CARTO_API_KEY=…` locally or through CI.
Do not commit the key. This is a client-distributed key, not a server secret;
configure provider restrictions appropriate for Android, and verify allowed headers.
No key means no tile requests and an explicit unavailable-basemap label.
All maps retain CARTO and OpenStreetMap attribution.
Official documentation checked: https://www.carto.com/basemaps/apikey/index.html
and https://www.carto.com/basemaps/ .

## Alerts and rollout

Legacy `/app?tab=alerts` lands on Home; generic notification/error fallback uses
`/app?section=alerts`. Fire ids retain `/fire/:id` navigation.
Received alerts are stored on-device (maximum 100) with persisted read state.
OS-delivered notifications received while the app is terminated enter this history
when opened; listing every unopened remote push requires a backend notification inbox.
Notification scope keeps the existing provider and backend synchronization.
Build code is 5. Store upload, merging and release signing remain separate actions.
