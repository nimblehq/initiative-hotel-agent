import { HotelSearchQuery, HotelSearchResult, HotelRoom } from "./types";

// Mock hotel list
class HotelDatabase {
  async searchHotels(query: HotelSearchQuery): Promise<HotelSearchResult> {
    // Simulate API call delay
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const mockRooms: HotelRoom[] = [
      {
        id: "booking-1",
        hotelName: "Grand Plaza Hotel",
        roomType: "Standard Room",
        price: 120,
        currency: "USD",
        description: "Comfortable room with city view",
        amenities: ["Free WiFi", "Air Conditioning", "Mini Bar"],
        rating: 4.2,
        location: query.destination,
        availability: true,
      },
      {
        id: "booking-2",
        hotelName: "Luxury Resort & Spa",
        roomType: "Deluxe Suite",
        price: 280,
        currency: "USD",
        description: "Luxurious suite with ocean view",
        amenities: ["Free WiFi", "Spa Access", "Ocean View", "Balcony"],
        rating: 4.8,
        location: query.destination,
        availability: true,
      },
      {
        id: "booking-3",
        hotelName: "Budget Stay",
        roomType: "Economy Room",
        price: 75,
        currency: "USD",
        description: "Clean and affordable accommodation",
        amenities: ["Free WiFi", "Parking"],
        rating: 3.8,
        location: query.destination,
        availability: true,
      },
      {
        id: "booking-4",
        hotelName: "Family Resort",
        roomType: "Family Suite",
        price: 200,
        currency: "USD",
        description: "Spacious suite perfect for families",
        amenities: ["Free WiFi", "Pool", "Kids Club", "Restaurant"],
        rating: 4.3,
        location: query.destination,
        availability: true,
      },
      {
        id: "booking-5",
        hotelName: "Business Inn",
        roomType: "Executive Room",
        price: 95,
        currency: "USD",
        description: "Modern room perfect for business travelers",
        amenities: ["Free WiFi", "Business Center", "Gym"],
        rating: 4.0,
        location: query.destination,
        availability: true,
      },
    ];

    return {
      rooms: mockRooms,
      totalResults: mockRooms.length,
      searchQuery: query,
    };
  }
}

export async function searchAllHotels(
  query: HotelSearchQuery
): Promise<HotelSearchResult> {
  try {
    const results = await new HotelDatabase().searchHotels(query);

    return results;
  } catch (error) {
    console.error("Error searching hotels:", error);
    throw new Error("Failed to search hotels");
  }
}
