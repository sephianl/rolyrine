use geo_types::LineString;
use polyline::{decode_polyline, encode_coordinates};
use rustler::NifResult;

#[rustler::nif]
fn decode_nif(encoded: String, precision: u32) -> NifResult<Vec<(f64, f64)>> {
    decode_polyline(&encoded, precision)
        .map(|ls| ls.coords().map(|c| (c.x, c.y)).collect())
        .map_err(|e| rustler::Error::Term(Box::new(format!("{:?}", e))))
}

#[rustler::nif]
fn encode_nif(coords: Vec<(f64, f64)>, precision: u32) -> NifResult<String> {
    let linestring: LineString<f64> = coords.into_iter().collect();
    encode_coordinates(linestring, precision)
        .map_err(|e| rustler::Error::Term(Box::new(format!("{:?}", e))))
}

rustler::init!("Elixir.Rolyrine");
