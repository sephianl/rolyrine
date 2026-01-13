# Rolyrine

Fast Google Polyline encoding/decoding for Elixir, powered by Rust NIFs.

Uses the [georust/polyline](https://github.com/georust/polyline) crate via [rustler_precompiled](https://hex.pm/packages/rustler_precompiled) for ~4-8x speedup over pure Elixir implementations.

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:rolyrine, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Encode coordinates to polyline
Rolyrine.encode([{-120.2, 38.5}, {-120.95, 40.7}])
#=> "_p~iF~ps|U_ulLnnqC"

# Decode polyline to coordinates
Rolyrine.decode("_p~iF~ps|U_ulLnnqC")
#=> [{-120.2, 38.5}, {-120.95, 40.7}]

# Decode with different output formats
Rolyrine.decode("_p~iF~ps|U_ulLnnqC", format: :lon_lat)
#=> [%{lon: -120.2, lat: 38.5}, %{lon: -120.95, lat: 40.7}]

# Use precision 6 (e.g., for OSRM)
Rolyrine.encode([{-120.2, 38.5}], precision: 6)
Rolyrine.decode("_izlhA~rlgdF", precision: 6)
```

### Supported Coordinate Formats

Encoding auto-detects format from the first element:

| Format | Example |
|--------|---------|
| `{lon, lat}` tuples | `[{-120.2, 38.5}, ...]` |
| `%{longitude:, latitude:}` | `[%{longitude: -120.2, latitude: 38.5}, ...]` |
| `%{lon:, lat:}` | `[%{lon: -120.2, lat: 38.5}, ...]` |
| `%{lng:, lat:}` | `[%{lng: -120.2, lat: 38.5}, ...]` |
| `%{x:, y:}` | `[%{x: -120.2, y: 38.5}, ...]` |

Decoding defaults to tuples; use `:format` option for maps.

## Building from Source

Set `ROLYRINE_BUILD=1` to compile the Rust NIF locally (requires Rust toolchain):

```bash
ROLYRINE_BUILD=1 mix deps.compile rolyrine
```

## License

MIT
