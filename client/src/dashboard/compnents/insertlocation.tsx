import React, { useState, useRef } from "react";
import { GoogleMap, LoadScript, Marker, StandaloneSearchBox } from "@react-google-maps/api";
import axios from "axios";
import "../../css/insertlocations.css";
import API_BASE_URL from "../../../config/ipconfig";

interface Location {
    lat: number;
    lng: number;
}

const defaultCenter: Location = {
    lat: 6.9271,
    lng: 79.8612,
};

const InsertLocations: React.FC = () => {
    const [hallName, setHallName] = useState("");
    const [location, setLocation] = useState<Location>(defaultCenter);
    const [loading, setLoading] = useState(false);

    const searchBoxRef = useRef<google.maps.places.SearchBox | null>(null);

    const handleMapClick = (e: google.maps.MapMouseEvent) => {
        if (e.latLng) {
            setLocation({
                lat: e.latLng.lat(),
                lng: e.latLng.lng(),
            });
        }
    };

    const handlePlacesChanged = () => {
        const places = searchBoxRef.current?.getPlaces();
        if (places && places.length > 0) {
            const place = places[0];
            if (place.geometry?.location) {
                setLocation({
                    lat: place.geometry.location.lat(),
                    lng: place.geometry.location.lng(),
                });
                setHallName(place.name || "");
            }
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        const payload = {
            name: hallName,
            latitude: location.lat,
            longitude: location.lng,
        };

        try {
            const res = await axios.post(`${API_BASE_URL}/locationinsert`, payload);
            console.log("Response:", res.data);
            alert("Lecture hall location saved successfully!");

            setHallName("");
            setLocation(defaultCenter);

        } catch (error) {
            console.error(error);
            alert("Failed to save location");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="location-page">
            <div className="location-card">
                <h2 className="location-title">Add Lecture Hall Location</h2>
                <p className="location-subtitle">
                    Search or click on the map to select the lecture hall location
                </p>

                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label>Lecture Hall Name</label>
                        <input
                            type="text"
                            placeholder="Eg: Hall A / Main Auditorium"
                            value={hallName}
                            onChange={(e) => setHallName(e.target.value)}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label>Search Location</label>
                        <LoadScript
                            googleMapsApiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}
                            libraries={["places"]}
                        >
                            <StandaloneSearchBox
                                onLoad={(ref) => (searchBoxRef.current = ref)}
                                onPlacesChanged={handlePlacesChanged}
                            >
                                <input
                                    type="text"
                                    placeholder="Search for lecture hall location..."
                                    className="search-box"
                                />
                            </StandaloneSearchBox>
                        </LoadScript>
                    </div>

                    <div className="map-container">
                        <LoadScript
                            googleMapsApiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}
                            libraries={["places"]}
                        >
                            <GoogleMap
                                mapContainerClassName="google-map"
                                center={location}
                                zoom={15}
                                onClick={handleMapClick}
                            >
                                <Marker position={location} />
                            </GoogleMap>
                        </LoadScript>
                    </div>

                    <div className="coordinates">
                        <span>
                            <strong>Latitude:</strong> {location.lat.toFixed(6)}
                        </span>
                        <span>
                            <strong>Longitude:</strong> {location.lng.toFixed(6)}
                        </span>
                    </div>

                    <button type="submit" className="save-btn" disabled={loading}>
                        {loading ? "Saving..." : "Save Location"}
                    </button>
                </form>
            </div>
        </div>
    );
};

export default InsertLocations;
