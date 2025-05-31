const BabysitterBookingHandler = require('../../services/booking/handlers/BabysitterBookingHandler');

exports.createBooking = async (req, res) => {
  try {
    const parentId = req.user._id;
    const bookingData = { ...req.body, parent_id: parentId };
    const io = req.app.get('io');

    const newBooking = await BabysitterBookingHandler.createBooking(bookingData, io);
    res.status(201).json({ status: true, message: 'Booking request sent.', data: newBooking });
  } catch (err) {
    res.status(500).json({ status: false, message: 'Failed to create booking.', error: err.message });
  }
};

exports.confirmBooking = async (req, res) => {
  const io = req.app.get('io');
  const updated = await BabysitterBookingHandler.confirmBooking(req.params.id, io);
  res.status(200).json({ message: 'Booking confirmed.', data: updated });
};

exports.rejectBooking = async (req, res) => {
  const updated = await BabysitterBookingHandler.rejectBooking(req.params.id);
  res.status(200).json({ message: 'Booking rejected.', data: updated });
};

exports.acceptBooking = async (req, res) => {
  const io = req.app.get('io');
  const updated = await BabysitterBookingHandler.acceptBooking(req.params.id, io);
  res.status(200).json({ message: 'Booking accepted.', data: updated });
};

exports.bookMeeting = async (req, res) => {
    const io = req.app.get('io');

  const updated = await BabysitterBookingHandler.bookMeeting(req.params.id, req.body, io);
  res.status(200).json({ message: 'Meeting booked.', data: updated });
};

exports.cancelBooking = async (req, res) => {
  const { cancelledBy, reason } = req.body;
console.log('🔸 Cancel request body:', req.body);
console.log('🔸 Cancelled by:', cancelledBy);
console.log('🔸 Reason:', reason);


  try {
    const updated = await BabysitterBookingHandler.cancelBooking(
      req.params.id,
      cancelledBy,
      reason // Pass reason to handler
    );

    res.status(200).json({ message: 'Booking canceled.', data: updated });
  } catch (error) {
    res.status(500).json({ error: error.message || 'Failed to cancel booking' });
  }
};

exports.markCompleted = async (req, res) => {
  const updated = await BabysitterBookingHandler.markCompleted(req.params.id);
  res.status(200).json({ message: 'Session marked as completed.', data: updated });
};

exports.markAsPaid = async (req, res) => {
  const updated = await BabysitterBookingHandler.markAsPaid(req.params.id);
  res.status(200).json({ message: 'Payment marked as successful.', data: updated });
};

exports.setPrice = async (req, res) => {
 const result = await BabysitterBookingHandler.setPrice(req.params.bookingId, req.body);
  res.status(200).json({ message: 'Price set successfully.', data: result });
};

exports.setPaymentMethod = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const { method } = req.body; // expecting 'cash' or 'online'
    const io = req.app.get('io');

    const updated = await BabysitterBookingHandler.setPaymentMethod(bookingId, method, io);
    res.status(200).json({ message: 'Payment method set and booking confirmed.', data: updated });
  } catch (err) {
    res.status(500).json({ message: 'Failed to set payment method.', error: err.message });
  }
};

