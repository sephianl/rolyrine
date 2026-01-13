defmodule RolyrineTest do
  use ExUnit.Case
  doctest Rolyrine

  @sample_polyline "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  @sample_coords [{-120.2, 38.5}, {-120.95, 40.7}, {-126.453, 43.252}]

  describe "decode/2" do
    test "decodes polyline to tuples by default" do
      assert Rolyrine.decode(@sample_polyline) == @sample_coords
    end

    test "decodes empty string to empty list" do
      assert Rolyrine.decode("") == []
    end

    test "decodes with format: :tuple" do
      assert Rolyrine.decode(@sample_polyline, format: :tuple) == @sample_coords
    end

    test "decodes with format: :longitude_latitude" do
      result = Rolyrine.decode(@sample_polyline, format: :longitude_latitude)

      assert result == [
               %{longitude: -120.2, latitude: 38.5},
               %{longitude: -120.95, latitude: 40.7},
               %{longitude: -126.453, latitude: 43.252}
             ]
    end

    test "decodes with format: :lon_lat" do
      result = Rolyrine.decode(@sample_polyline, format: :lon_lat)

      assert result == [
               %{lon: -120.2, lat: 38.5},
               %{lon: -120.95, lat: 40.7},
               %{lon: -126.453, lat: 43.252}
             ]
    end

    test "decodes with format: :lng_lat" do
      result = Rolyrine.decode(@sample_polyline, format: :lng_lat)

      assert result == [
               %{lng: -120.2, lat: 38.5},
               %{lng: -120.95, lat: 40.7},
               %{lng: -126.453, lat: 43.252}
             ]
    end

    test "decodes with format: :xy" do
      result = Rolyrine.decode(@sample_polyline, format: :xy)

      assert result == [
               %{x: -120.2, y: 38.5},
               %{x: -120.95, y: 40.7},
               %{x: -126.453, y: 43.252}
             ]
    end

    test "decodes with precision: 6" do
      polyline_p6 = "_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI"
      result = Rolyrine.decode(polyline_p6, precision: 6)
      assert result == @sample_coords
    end
  end

  describe "encode/2" do
    test "encodes tuples to polyline" do
      assert Rolyrine.encode(@sample_coords) == @sample_polyline
    end

    test "encodes empty list to empty string" do
      assert Rolyrine.encode([]) == ""
    end

    test "encodes %{longitude:, latitude:} format" do
      coords = [
        %{longitude: -120.2, latitude: 38.5},
        %{longitude: -120.95, latitude: 40.7},
        %{longitude: -126.453, latitude: 43.252}
      ]

      assert Rolyrine.encode(coords) == @sample_polyline
    end

    test "encodes %{lon:, lat:} format" do
      coords = [
        %{lon: -120.2, lat: 38.5},
        %{lon: -120.95, lat: 40.7},
        %{lon: -126.453, lat: 43.252}
      ]

      assert Rolyrine.encode(coords) == @sample_polyline
    end

    test "encodes %{lng:, lat:} format" do
      coords = [
        %{lng: -120.2, lat: 38.5},
        %{lng: -120.95, lat: 40.7},
        %{lng: -126.453, lat: 43.252}
      ]

      assert Rolyrine.encode(coords) == @sample_polyline
    end

    test "encodes %{x:, y:} format" do
      coords = [
        %{x: -120.2, y: 38.5},
        %{x: -120.95, y: 40.7},
        %{x: -126.453, y: 43.252}
      ]

      assert Rolyrine.encode(coords) == @sample_polyline
    end

    test "encodes with precision: 6" do
      result = Rolyrine.encode(@sample_coords, precision: 6)
      assert result == "_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI"
    end
  end

  describe "round trip" do
    test "encode then decode returns original" do
      coords = [{-122.4194, 37.7749}, {-118.2437, 34.0522}, {-73.9857, 40.7484}]
      encoded = Rolyrine.encode(coords)
      decoded = Rolyrine.decode(encoded)
      assert decoded == coords
    end
  end
end
