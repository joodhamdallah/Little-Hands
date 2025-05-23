// services/booking/BookingService.js

const BabysitterBookingHandler = require('././handlers/BabysitterBookingHandler');
// const SpecialNeedsBookingHandler = require('./handlers/SpecialNeedsBookingHandler');
// const ExpertBookingHandler = require('./handlers/ExpertBookingHandler');

class BookingService {
  static async createBooking(bookingData, io) {
    switch (bookingData.service_type) {
      case 'babysitter':
        return await BabysitterBookingHandler.handle(bookingData, io);
      // case 'special_needs':
      //   return await SpecialNeedsBookingHandler.handle(bookingData);
      // case 'expert':
      //   return await ExpertBookingHandler.handle(bookingData);
      default:
        throw new Error('Unsupported service type');
    }
  }
}

module.exports = BookingService;
