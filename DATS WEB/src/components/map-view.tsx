import { useEffect } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

// Fix for leaflet default marker icon in React/Vite
const fixLeafletIcon = () => {
  delete (L.Icon.Default.prototype as any)._getIconUrl;
  L.Icon.Default.mergeOptions({
    iconRetinaUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png",
    iconUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png",
    shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
  });
};

interface MapViewProps {
  lat?: number;
  lng?: number;
  zoom?: number;
  label?: string;
  className?: string;
}

export function MapView({
  lat = 15.4607,
  lng = 36.4,
  zoom = 14,
  label = "الاتمتة الرقمية - كسلا، السودان",
  className = "h-56 w-full rounded-2xl"
}: MapViewProps) {
  useEffect(() => {
    fixLeafletIcon();
  }, []);

  return (
    <MapContainer
      center={[lat, lng]}
      zoom={zoom}
      className={className}
      scrollWheelZoom={false}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      <Marker position={[lat, lng]}>
        <Popup>
          <div className="text-center text-sm font-medium">{label}</div>
        </Popup>
      </Marker>
    </MapContainer>
  );
}

export { MapView as oK };
