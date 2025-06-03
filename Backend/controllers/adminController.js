const Parent = require('../models/Parent');
const CareGiver = require('../models/CareGiver');
const Booking = require('../models/Booking');
const ExpertPost = require('../models/ExpertPost');
const moment = require('moment'); 

exports.getSummary = async (req, res) => {
  try {
    const parents = await Parent.countDocuments();
    const caregivers = await CareGiver.countDocuments();
    const bookings = await Booking.countDocuments();
    const posts = await ExpertPost.countDocuments();

    res.json({ parents, caregivers, bookings, posts });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};


exports.getBookingTrends = async (req, res) => {
  try {
    const today = moment().startOf('day');
    const last7Days = [...Array(7)].map((_, i) =>
      today.clone().subtract(6 - i, 'days')
    );

    const trendData = await Promise.all(
      last7Days.map(async (day) => {
        const count = await Booking.countDocuments({
          session_start_date: {
            $gte: day.toDate(),
            $lt: day.clone().add(1, 'day').toDate(),
          },
        });

        return {
          day: day.format('ddd'),
          bookings: count,
        };
      })
    );

    res.json(trendData);
  } catch (err) {
    console.error('📉 Failed to fetch booking trends', err);
    res.status(500).json({ error: 'Failed to load trends' });
  }
};



exports.getAllUsers = async (req, res) => {
  try {
    const caregivers = await CareGiver.find().select('first_name last_name email role city createdAt');
    const parents = await Parent.find().select('firstName lastName email city createdAt');

    const formattedCaregivers = caregivers.map(c => ({
      name: `${c.first_name} ${c.last_name}`,
      email: c.email,
      role: c.role,
      city: c.city,
      joined: c.createdAt,
      type: 'caregiver',
      id: c._id
    }));

    const formattedParents = parents.map(p => ({
      name: `${p.firstName} ${p.lastName}`, 
      email: p.email,
      role: 'parent',
      city: p.city,
      joined: p.createdAt,
      type: 'parent',
      id: p._id
    }));

    res.json([...formattedCaregivers, ...formattedParents]);
  } catch (err) {
    console.error('❌ Failed to fetch users:', err);
    res.status(500).json({ message: 'Server error' });
  }
};


exports.deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    const deletedFromCaregivers = await CareGiver.findByIdAndDelete(id);
    const deletedFromParents = await Parent.findByIdAndDelete(id);

    if (!deletedFromCaregivers && !deletedFromParents) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('❌ Error deleting user:', err);
    res.status(500).json({ message: 'Server error' });
  }
};
