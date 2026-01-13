defmodule Rolyrine do
  @moduledoc """
  Fast polyline encoding/decoding using Rust NIFs.

  Implements Google's Polyline Algorithm Format with flexible coordinate formats.

  ## Supported Coordinate Formats

  | Format | Example |
  |--------|---------|
  | `{lon, lat}` tuples | `[{-120.2, 38.5}, ...]` |
  | `%{longitude:, latitude:}` | `[%{longitude: -120.2, latitude: 38.5}, ...]` |
  | `%{lon:, lat:}` | `[%{lon: -120.2, lat: 38.5}, ...]` |
  | `%{lng:, lat:}` | `[%{lng: -120.2, lat: 38.5}, ...]` |
  | `%{x:, y:}` | `[%{x: -120.2, y: 38.5}, ...]` |

  ## Examples

      iex> Rolyrine.encode([{-120.2, 38.5}, {-120.95, 40.7}])
      "_p~iF~ps|U_ulLnnqC"

      iex> Rolyrine.decode("_p~iF~ps|U_ulLnnqC")
      [{-120.2, 38.5}, {-120.95, 40.7}]

      iex> Rolyrine.decode("_p~iF~ps|U_ulLnnqC", format: :longitude_latitude)
      [%{longitude: -120.2, latitude: 38.5}, %{longitude: -120.95, latitude: 40.7}]
  """

  @version "0.1.0"

  use RustlerPrecompiled,
    otp_app: :rolyrine,
    crate: "rolyrine",
    base_url: "https://github.com/sephianl/rolyrine/releases/download/v#{@version}",
    force_build: System.get_env("ROLYRINE_BUILD") in ["1", "true"],
    version: @version,
    targets: [
      "aarch64-apple-darwin",
      "aarch64-unknown-linux-gnu",
      "x86_64-unknown-linux-gnu",
      "x86_64-pc-windows-msvc",
      "x86_64-pc-windows-gnu"
    ],
    nif_versions: ["2.15", "2.16", "2.17"]

  @default_precision 5

  # ============================================================================
  # DECODE
  # ============================================================================

  @doc """
  Decode a polyline string into a list of coordinates.

  ## Options

    * `:precision` - decimal precision (default: 5)
    * `:format` - output format (default: `:tuple`)
      - `:tuple` - `[{lon, lat}, ...]`
      - `:longitude_latitude` - `[%{longitude: lon, latitude: lat}, ...]`
      - `:lon_lat` - `[%{lon: lon, lat: lat}, ...]`
      - `:lng_lat` - `[%{lng: lon, lat: lat}, ...]`
      - `:xy` - `[%{x: lon, y: lat}, ...]`

  ## Examples

      iex> Rolyrine.decode("_p~iF~ps|U_ulLnnqC")
      [{-120.2, 38.5}, {-120.95, 40.7}]

      iex> Rolyrine.decode("_p~iF~ps|U_ulLnnqC", format: :lon_lat)
      [%{lon: -120.2, lat: 38.5}, %{lon: -120.95, lat: 40.7}]

      iex> Rolyrine.decode("_izlhA~rlgdF_{geC~ywl@", precision: 6)
      [{-120.2, 38.5}, {-120.95, 40.7}]
  """
  def decode(polyline, opts \\ [])
  def decode("", _opts), do: []

  def decode(polyline, opts) do
    precision = Keyword.get(opts, :precision, @default_precision)
    format = Keyword.get(opts, :format, :tuple)

    case decode_nif(polyline, precision) do
      {:error, _} = error -> error
      coords -> to_format(coords, format)
    end
  end

  defp to_format({:error, _} = error, _format), do: error
  defp to_format(coords, :tuple), do: coords

  defp to_format(coords, :longitude_latitude) do
    Enum.map(coords, fn {lon, lat} -> %{longitude: lon, latitude: lat} end)
  end

  defp to_format(coords, :lon_lat) do
    Enum.map(coords, fn {lon, lat} -> %{lon: lon, lat: lat} end)
  end

  defp to_format(coords, :lng_lat) do
    Enum.map(coords, fn {lon, lat} -> %{lng: lon, lat: lat} end)
  end

  defp to_format(coords, :xy) do
    Enum.map(coords, fn {lon, lat} -> %{x: lon, y: lat} end)
  end

  # ============================================================================
  # ENCODE
  # ============================================================================

  @doc """
  Encode a list of coordinates into a polyline string.

  Accepts multiple coordinate formats - auto-detected from first element.

  ## Options

    * `:precision` - decimal precision (default: 5)

  ## Examples

      iex> Rolyrine.encode([{-120.2, 38.5}, {-120.95, 40.7}])
      "_p~iF~ps|U_ulLnnqC"

      iex> Rolyrine.encode([%{longitude: -120.2, latitude: 38.5}, %{longitude: -120.95, latitude: 40.7}])
      "_p~iF~ps|U_ulLnnqC"

      iex> Rolyrine.encode([{-120.2, 38.5}, {-120.95, 40.7}], precision: 6)
      "_izlhA~rlgdF_{geC~ywl@"
  """
  def encode(coords, opts \\ [])
  def encode([], _opts), do: ""

  def encode([{_lon, _lat} | _] = coords, opts) do
    encode_tuples(coords, opts)
  end

  def encode([%{longitude: _, latitude: _} | _] = coords, opts) do
    coords
    |> Enum.map(fn %{longitude: lon, latitude: lat} -> {lon, lat} end)
    |> encode_tuples(opts)
  end

  def encode([%{lon: _, lat: _} | _] = coords, opts) do
    coords
    |> Enum.map(fn %{lon: lon, lat: lat} -> {lon, lat} end)
    |> encode_tuples(opts)
  end

  def encode([%{lng: _, lat: _} | _] = coords, opts) do
    coords
    |> Enum.map(fn %{lng: lon, lat: lat} -> {lon, lat} end)
    |> encode_tuples(opts)
  end

  def encode([%{x: _, y: _} | _] = coords, opts) do
    coords
    |> Enum.map(fn %{x: lon, y: lat} -> {lon, lat} end)
    |> encode_tuples(opts)
  end

  defp encode_tuples(coords, opts) do
    precision = Keyword.get(opts, :precision, @default_precision)
    encode_nif(coords, precision)
  end

  # ============================================================================
  # NIF STUBS
  # ============================================================================

  defp decode_nif(_polyline, _precision), do: :erlang.nif_error(:nif_not_loaded)
  defp encode_nif(_coords, _precision), do: :erlang.nif_error(:nif_not_loaded)
end
