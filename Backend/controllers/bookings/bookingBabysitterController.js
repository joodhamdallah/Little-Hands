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
  const updated = await BabysitterBookingHandler.cancelBooking(req.params.id, req.body.cancelledBy);
  res.status(200).json({ message: 'Booking canceled.', data: updated });
};

exports.markCompleted = async (req, res) => {
  const updated = await BabysitterBookingHandler.markCompleted(req.params.id);
  res.status(200).json({ message: 'Session marked as completed.', data: updated });
};

exports.markAsPaid = async (req, res) => {
  const updated = await BabysitterBookingHandler.markAsPaid(req.params.id);
  res.status(200).json({ message: 'Payment marked as successful.', data: updated });
};
