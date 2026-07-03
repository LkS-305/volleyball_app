package config

import "os"

// Config holds runtime settings, all sourced from environment variables so no
// secrets are committed. See .env.example for the full list.
type Config struct {
	StoreBackend      string // "json" (default) or "sheets"
	JSONPath          string // JSON store file path (json backend)
	SheetsCredentials string // path to the service-account JSON key (sheets backend)
	SpreadsheetID     string // target spreadsheet id (sheets backend)
	Port              string // HTTP listen port
}

// Load reads configuration from the environment, applying sensible defaults.
func Load() Config {
	return Config{
		StoreBackend:      getenv("STORE_BACKEND", "json"),
		JSONPath:          getenv("JSON_STORE_PATH", "data/sessions.json"),
		SheetsCredentials: getenv("GOOGLE_SHEETS_CREDENTIALS_PATH", ""),
		SpreadsheetID:     getenv("GOOGLE_SHEETS_SPREADSHEET_ID", ""),
		Port:              getenv("PORT", "8080"),
	}
}

func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
