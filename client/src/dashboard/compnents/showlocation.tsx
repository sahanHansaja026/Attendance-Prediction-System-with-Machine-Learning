import React, { useEffect, useState } from "react";
import axios from "axios";
import { GoogleMap, LoadScript, Marker, InfoWindow } from "@react-google-maps/api";
import API_BASE_URL from "../../../config/ipconfig";
import "../../css/showlocation.css";

interface Location {
    id: number;
    name: string;
    latitude: number;
    longitude: number;
}

const defaultCenter = {
    lat: 6.9271,
    lng: 79.8612,
};

function ShowLocation() {
    const [locations, setLocations] = useState<Location[]>([]);
    const [selectedLocation, setSelectedLocation] = useState<Location | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        axios.get(`${API_BASE_URL}/locations`)
            .then(res => {
                setLocations(res.data);
                setLoading(false);
            })
            .catch(err => {
                console.error("Error loading locations:", err);
                setLoading(false);
            });
    }, []);

    return (
        <div className="map-page">
            <div className="map-header">
                <h2>📍 Locations Map</h2>
                <p>View all saved locations on the map</p>
            </div>

            <div className="map-card">
                {loading ? (
                    <p className="loading-text">Loading locations...</p>
                ) : (
                    <LoadScript
                        googleMapsApiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}
                        libraries={["places"]}
                    >
                        <GoogleMap
                            mapContainerClassName="google-map"
                            center={defaultCenter}
                            zoom={14}
                        >
                            {locations.map((loc) => (
                                <Marker
                                    key={loc.id}
                                    position={{ lat: loc.latitude, lng: loc.longitude }}
                                    onClick={() => setSelectedLocation(loc)}
                                />
                            ))}

                            {selectedLocation && (
                                <InfoWindow
                                    position={{
                                        lat: selectedLocation.latitude,
                                        lng: selectedLocation.longitude
                                    }}
                                    onCloseClick={() => setSelectedLocation(null)}
                                >
                                    <div className="info-window">
                                        <h4>{selectedLocation.name}</h4>
                                        <p>Lat: {selectedLocation.latitude}</p>
                                        <p>Lng: {selectedLocation.longitude}</p>
                                    </div>
                                </InfoWindow>
                            )}
                        </GoogleMap>
                    </LoadScript>
                )}
            </div>
        </div>
    );
}

export default ShowLocation;
