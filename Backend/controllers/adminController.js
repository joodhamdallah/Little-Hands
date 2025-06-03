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


exports.getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('parent_id', 'firstName lastName')
      .populate('caregiver_id', 'first_name last_name')
      .sort({ createdAt: -1 });

    const result = bookings.map(b => ({
      parent: {
        name: `${b.parent_id?.firstName || ''} ${b.parent_id?.lastName || ''}`
      },
      caregiver: {
        name: `${b.caregiver_id?.first_name || ''} ${b.caregiver_id?.last_name || ''}`
      },
      service_type: b.service_type,
      session_start_date: b.session_start_date,
      status: b.status,
      price_details: b.price_details
    }));

    res.json(result);
  } catch (err) {
    console.error('❌ Failed to get bookings:', err);
    res.status(500).json({ message: 'Server error' });
  }
};


exports.getAllExpertPosts = async (req, res) => {
  try {
    const posts = await ExpertPost.find()
      .populate('expert_id', 'first_name last_name') // only get name
      .sort({ created_at: -1 });

    const formatted = posts.map(post => ({
      _id: post._id,
      title: post.title,
      summary: post.summary,
      expertName: `${post.expert_id?.first_name || 'Unknown'} ${post.expert_id?.last_name || ''}`,
      pdf_url: post.pdf_url,
      image_url: post.image_url,
      createdAt: post.created_at
    }));

    res.json(formatted);
  } catch (err) {
    console.error('❌ Failed to get expert posts:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteExpertPost = async (req, res) => {
  const { id } = req.params;
  try {
    const deleted = await ExpertPost.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ message: 'Post not found' });
    }
    res.json({ message: 'Post deleted successfully' });
  } catch (err) {
    console.error('❌ Failed to delete expert post:', err);
    res.status(500).json({ message: 'Server error' });
  }
};