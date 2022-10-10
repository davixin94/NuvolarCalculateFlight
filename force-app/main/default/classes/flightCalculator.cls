public with sharing class flightCalculator {

    @AuraEnabled
    public static Map<String, String> getAvailableAirports(){
        Map<String, String> result = new Map<String, String>();
        List<Airport__c> airports = new List<Airport__c>();
        String aux = '';
        try {
            airports = [
                SELECT 
                Id, Name, IATA_Code__c
                FROM Airport__c
                LIMIT 300
            ];
            for(Airport__c a : airports){
                result.put(a.IATA_Code__c, a.Name);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Decimal calculateFlight(String departure, String arrival){
        Airport__c departureAirport = new Airport__c();
        Airport__c arrivalAirport = new Airport__c();
        Decimal distance = 0.0;
        try{
            departureAirport = [SELECT Id, Longitude__c, Latitude__c FROM Airport__c WHERE IATA_Code__c = :departure LIMIT 1];
            arrivalAirport = [SELECT Id, Longitude__c, Latitude__c FROM Airport__c WHERE IATA_Code__c = :arrival LIMIT 1];
            distance = calculateDistance(departureAirport.Latitude__c, departureAirport.Longitude__c, arrivalAirport.Latitude__c, arrivalAirport.Longitude__c);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return distance;
    }

    @AuraEnabled
    public static void saveFlight(String departure, String arrival, Decimal distance){
        Airport__c departureAirport = new Airport__c();
        Airport__c arrivalAirport = new Airport__c();
        Flight__c flight = new Flight__c();
        try {
            departureAirport = [SELECT Id FROM Airport__c WHERE IATA_Code__c = :departure LIMIT 1];
            arrivalAirport = [SELECT Id FROM Airport__c WHERE IATA_Code__c = :arrival LIMIT 1];
            flight.Arrival__c = arrivalAirport.Id;
            flight.Departure__c = departureAirport.Id;
            flight.Distance__c = distance;
            upsert flight;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static Decimal calculateDistance(Decimal latitude1, Decimal longitude1,
        Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371 * 1000; // in meters
        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
        Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
        Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance;
    }
}
