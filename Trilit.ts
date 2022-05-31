/**
 * @license
 * Copyright 2019 Google LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

// This example creates circles on the map, representing populations in North
// America.

// First, create an object containing LatLng and population for each city.
// Initialize and add the map

interface City {
  center: google.maps.LatLngLiteral;
  radius: number;
}

const citymap: Record<string, City> = {
  chicago: {
    center: { lat: 46.0674749798995, lng: 11.15111384638543 },
    radius: 77.45263
  },
  newyork: {
    center: { lat: 46.06746707029327, lng: 11.15162413599556 },
    radius: 82.40549
  },
  losangeles: {
    center: { lat: 46.06820775846681, lng: 11.151114348093234 },
    radius: 12.17063
  }
};

function initMap(): void {
  // Create the map.
  const map = new google.maps.Map(
    document.getElementById("map") as HTMLElement,
    {
      zoom: 4,
      center: { lat: 46.0674749798995, lng: 11.15111384638543 },
      mapTypeId: "terrain"
    }
  );

  // Construct the circle for each value in citymap.
  // Note: We scale the area of the circle based on the population.
  for (const city in citymap) {
    // Add the circle for this city to the map.
    const cityCircle = new google.maps.Circle({
      strokeColor: "#FF0000",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: "#FF0000",
      fillOpacity: 0.35,
      map,
      center: citymap[city].center,
      radius: citymap[city].radius
    });
    // The marker, positioned at Uluru
    const marker = new google.maps.Marker({
      position: { lat: 46.06816571239967, lng: 11.151260403435263 },
      map: map
    });
    const image =
      "https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png";
    const beachMarker = new google.maps.Marker({
      position: { lat: 46.0681657124098, lng: 11.151260404212527 },
      map,
      icon: image
    });
  }
}

declare global {
  interface Window {
    initMap: () => void;
  }
}
window.initMap = initMap;

