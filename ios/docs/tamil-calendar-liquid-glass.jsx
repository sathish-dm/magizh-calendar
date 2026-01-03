import React, { useState } from 'react';
import { Calendar, Sun, Moon, Clock, UtensilsCrossed, MapPin, ChevronLeft, ChevronRight } from 'lucide-react';

const TamilCalendarLiquidGlass = () => {
  const [view, setView] = useState('daily'); // 'daily' or 'weekly'
  const [selectedDate, setSelectedDate] = useState(new Date(2026, 0, 2)); // Jan 2, 2026

  // Mock data
  const tamilData = {
    tamilDate: 'Thai 16',
    tamilDay: 'Velli',
    nakshatram: 'Rohini',
    nakshatramEnd: '2:45 PM',
    thithi: 'Panchami',
    thithiEnd: '4:30 PM',
    paksha: 'Shukla',
    yogam: 'Amirtha Yogam',
    yogamType: 'auspicious',
    yogamStart: '8:30 AM',
    yogamEnd: '2:15 PM',
    karanam: 'Bava',
    karanamEnd: '10:15 AM',
    sunrise: '6:42 AM',
    sunset: '5:54 PM',
    nallaNeram: '9:15 AM - 10:30 AM',
    rahukaalam: '1:30 PM - 3:00 PM',
    yamagandam: '9:00 AM - 10:30 AM',
    foodStatus: 'regular',
    nextAuspicious: 'Pradosham (Tomorrow)',
    location: 'Chennai, Tamil Nadu'
  };

  const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                      'July', 'August', 'September', 'October', 'November', 'December'];

  // Generate week data (mock)
  const generateWeekData = () => {
    const week = [];
    const yogams = ['Regular', 'Amirtha', 'Siddha', 'Regular', 'Marana', 'Amirtha', 'Regular'];
    for (let i = 0; i < 7; i++) {
      const date = new Date(2026, 0, i + 1);
      week.push({
        date: date.getDate(),
        day: weekDays[date.getDay()],
        tamilDate: `Thai ${11 + i}`,
        isToday: i === 1,
        isAuspicious: i === 2 || i === 4,
        auspiciousType: i === 2 ? 'Pradosham' : i === 4 ? 'Ekadasi' : null,
        yogam: yogams[i] !== 'Regular' ? yogams[i] : null
      });
    }
    return week;
  };

  const weekData = generateWeekData();

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-100 via-blue-50 to-purple-50 p-4 font-sans">
      <style>{`
        @keyframes shimmer {
          0% { background-position: -200% 0; }
          100% { background-position: 200% 0; }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px) saturate(180%);
          -webkit-backdrop-filter: blur(20px) saturate(180%);
          border: 1px solid rgba(255, 255, 255, 0.3);
          box-shadow: 
            0 8px 32px 0 rgba(31, 38, 135, 0.15),
            inset 0 1px 0 0 rgba(255, 255, 255, 0.5);
        }
        
        .glass-card-dark {
          background: rgba(255, 255, 255, 0.5);
          backdrop-filter: blur(16px) saturate(180%);
          -webkit-backdrop-filter: blur(16px) saturate(180%);
          border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .glass-header {
          background: linear-gradient(135deg, rgba(255, 127, 80, 0.95) 0%, rgba(255, 99, 71, 0.9) 100%);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          box-shadow: 
            0 8px 32px 0 rgba(255, 99, 71, 0.3),
            inset 0 1px 0 0 rgba(255, 255, 255, 0.3);
        }
        
        .floating {
          animation: float 3s ease-in-out infinite;
        }
        
        @keyframes float {
          0%, 100% { transform: translateY(0px); }
          50% { transform: translateY(-5px); }
        }
        
        .glow-auspicious {
          box-shadow: 
            0 0 20px rgba(16, 185, 129, 0.3),
            0 8px 32px 0 rgba(31, 38, 135, 0.15),
            inset 0 1px 0 0 rgba(255, 255, 255, 0.5);
        }
        
        .glow-warning {
          box-shadow: 
            0 0 20px rgba(239, 68, 68, 0.3),
            0 8px 32px 0 rgba(31, 38, 135, 0.15),
            inset 0 1px 0 0 rgba(255, 255, 255, 0.5);
        }
      `}</style>

      <div className="max-w-md mx-auto">
        {/* Header with Liquid Glass Effect */}
        <div className="glass-header rounded-[32px] overflow-hidden mb-4 shadow-2xl">
          <div className="p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2 text-sm font-medium backdrop-blur-sm bg-white/10 px-3 py-1.5 rounded-full">
                <MapPin size={14} />
                <span>{tamilData.location}</span>
              </div>
              <button className="p-2 hover:bg-white/20 rounded-full transition backdrop-blur-sm">
                <Calendar size={20} />
              </button>
            </div>
            
            <div className="text-center">
              <div className="text-7xl font-bold mb-2 drop-shadow-lg floating">
                {selectedDate.getDate()}
              </div>
              <div className="text-xl font-medium opacity-95 mb-1">
                {weekDays[selectedDate.getDay()]}, {monthNames[selectedDate.getMonth()]} {selectedDate.getFullYear()}
              </div>
              <div className="text-sm mt-2 opacity-90 backdrop-blur-sm bg-white/10 inline-block px-4 py-1 rounded-full">
                {tamilData.tamilDate} • {tamilData.tamilDay}
              </div>
            </div>
          </div>

          {/* View Toggle with Glass Effect */}
          <div className="flex bg-black/10 backdrop-blur-md">
            <button
              onClick={() => setView('daily')}
              className={`flex-1 py-3 text-sm font-medium transition ${
                view === 'daily' 
                  ? 'bg-white/30 text-white backdrop-blur-lg' 
                  : 'text-white/70 hover:text-white hover:bg-white/10'
              }`}
            >
              Daily View
            </button>
            <button
              onClick={() => setView('weekly')}
              className={`flex-1 py-3 text-sm font-medium transition ${
                view === 'weekly' 
                  ? 'bg-white/30 text-white backdrop-blur-lg' 
                  : 'text-white/70 hover:text-white hover:bg-white/10'
              }`}
            >
              Weekly View
            </button>
          </div>
        </div>

        {/* Daily View */}
        {view === 'daily' && (
          <div className="space-y-4">
            {/* Food Status Card - Liquid Glass */}
            <div className={`glass-card rounded-3xl p-5 ${
              tamilData.foodStatus === 'regular' ? 'glow-auspicious' : 'glow-warning'
            }`}>
              <div className="flex items-start gap-4">
                <div className={`p-3 rounded-2xl ${
                  tamilData.foodStatus === 'regular' 
                    ? 'bg-gradient-to-br from-green-400/30 to-emerald-500/30 backdrop-blur-sm' 
                    : 'bg-gradient-to-br from-red-400/30 to-rose-500/30 backdrop-blur-sm'
                }`}>
                  <UtensilsCrossed 
                    size={24} 
                    className={
                      tamilData.foodStatus === 'regular' 
                        ? 'text-green-700' 
                        : 'text-red-700'
                    } 
                  />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900 mb-1">
                    {tamilData.foodStatus === 'regular' ? '✅ Regular Day' : '⚠️ Auspicious Day'}
                  </h3>
                  <p className="text-sm text-gray-700 mb-2">
                    {tamilData.foodStatus === 'regular' 
                      ? 'Safe to cook non-veg' 
                      : 'Avoid cooking non-veg'}
                  </p>
                  <div className="flex items-center gap-2 text-xs bg-orange-500/20 backdrop-blur-sm px-3 py-1.5 rounded-full inline-flex text-orange-800 font-medium">
                    <span>⚠️ {tamilData.nextAuspicious}</span>
                  </div>
                  <p className="text-xs text-gray-600 mt-2">
                    Avoid storing overnight
                  </p>
                </div>
              </div>
            </div>

            {/* Panchangam Details - Five Angams with Liquid Glass */}
            <div className="glass-card rounded-3xl p-5">
              <h3 className="font-semibold text-gray-900 mb-1 flex items-center gap-2">
                <div className="p-1.5 bg-gradient-to-br from-orange-400/30 to-red-500/30 rounded-lg backdrop-blur-sm">
                  <Sun size={16} className="text-orange-700" />
                </div>
                Today's Panchangam
              </h3>
              <p className="text-xs text-gray-500 mb-4">Five Elements of Time</p>
              
              <div className="space-y-3">
                {/* Nakshatram */}
                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-purple-400">
                  <div className="flex justify-between items-start mb-1">
                    <span className="text-xs font-medium text-purple-900">⭐ Nakshatram</span>
                    <span className="text-[10px] text-purple-700 bg-purple-100/50 px-2 py-0.5 rounded-full">
                      Ends {tamilData.nakshatramEnd}
                    </span>
                  </div>
                  <div className="text-sm font-bold text-purple-900">{tamilData.nakshatram}</div>
                </div>

                {/* Thithi */}
                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-blue-400">
                  <div className="flex justify-between items-start mb-1">
                    <span className="text-xs font-medium text-blue-900">🌙 Thithi</span>
                    <span className="text-[10px] text-blue-700 bg-blue-100/50 px-2 py-0.5 rounded-full">
                      Ends {tamilData.thithiEnd}
                    </span>
                  </div>
                  <div className="text-sm font-bold text-blue-900">
                    {tamilData.thithi} ({tamilData.paksha} Paksha)
                  </div>
                </div>

                {/* Yogam - Highlighted with Glow */}
                <div className={`glass-card-dark rounded-2xl p-3 border-l-4 ${
                  tamilData.yogamType === 'auspicious' 
                    ? 'border-green-400 glow-auspicious' 
                    : 'border-red-400 glow-warning'
                }`}>
                  <div className="flex justify-between items-start mb-1">
                    <span className={`text-xs font-medium ${
                      tamilData.yogamType === 'auspicious' ? 'text-green-900' : 'text-red-900'
                    }`}>
                      ✨ Yogam
                    </span>
                    <span className={`text-[9px] px-2 py-1 rounded-full font-semibold ${
                      tamilData.yogamType === 'auspicious' 
                        ? 'bg-gradient-to-r from-green-500 to-emerald-600 text-white shadow-lg' 
                        : 'bg-gradient-to-r from-red-500 to-rose-600 text-white shadow-lg'
                    }`}>
                      {tamilData.yogamType === 'auspicious' ? 'AUSPICIOUS' : 'AVOID'}
                    </span>
                  </div>
                  <div className={`text-sm font-bold mb-1 ${
                    tamilData.yogamType === 'auspicious' ? 'text-green-900' : 'text-red-900'
                  }`}>
                    {tamilData.yogam}
                  </div>
                  <div className={`text-xs ${
                    tamilData.yogamType === 'auspicious' ? 'text-green-700' : 'text-red-700'
                  }`}>
                    {tamilData.yogamStart} - {tamilData.yogamEnd}
                  </div>
                  {tamilData.yogamType === 'auspicious' && (
                    <div className="text-[10px] text-green-700 mt-1 bg-green-100/50 px-2 py-1 rounded-lg inline-block">
                      Excellent for: New ventures, important decisions
                    </div>
                  )}
                </div>

                {/* Karanam */}
                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-indigo-400">
                  <div className="flex justify-between items-start mb-1">
                    <span className="text-xs font-medium text-indigo-900">🔄 Karanam</span>
                    <span className="text-[10px] text-indigo-700 bg-indigo-100/50 px-2 py-0.5 rounded-full">
                      Ends {tamilData.karanamEnd}
                    </span>
                  </div>
                  <div className="text-sm font-bold text-indigo-900">{tamilData.karanam}</div>
                </div>

                {/* Sunrise/Sunset */}
                <div className="glass-card-dark rounded-2xl p-3">
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2">
                      <Sun size={14} className="text-orange-500" />
                      <span className="text-xs text-gray-700">Sunrise</span>
                    </div>
                    <span className="text-xs font-semibold text-gray-900">{tamilData.sunrise}</span>
                  </div>
                  <div className="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent my-2"></div>
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2">
                      <Moon size={14} className="text-indigo-500" />
                      <span className="text-xs text-gray-700">Sunset</span>
                    </div>
                    <span className="text-xs font-semibold text-gray-900">{tamilData.sunset}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Timings with Glass Effects */}
            <div className="glass-card rounded-3xl p-5">
              <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <div className="p-1.5 bg-gradient-to-br from-orange-400/30 to-red-500/30 rounded-lg backdrop-blur-sm">
                  <Clock size={16} className="text-orange-700" />
                </div>
                Auspicious Timings
              </h3>
              
              <div className="space-y-3">
                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-green-400 glow-auspicious">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-medium text-green-900">✅ Nalla Neram</span>
                    <span className="text-[10px] bg-green-500/20 text-green-800 px-2 py-1 rounded-full font-semibold">
                      Best Time
                    </span>
                  </div>
                  <div className="text-sm text-green-800 font-semibold">
                    {tamilData.nallaNeram}
                  </div>
                </div>

                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-red-400">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-medium text-red-900">❌ Rahukaalam</span>
                    <span className="text-[10px] bg-red-500/20 text-red-800 px-2 py-1 rounded-full font-semibold">
                      Avoid
                    </span>
                  </div>
                  <div className="text-sm text-red-800 font-semibold">
                    {tamilData.rahukaalam}
                  </div>
                </div>

                <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-amber-400">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-medium text-amber-900">⚠️ Yamagandam</span>
                    <span className="text-[10px] bg-amber-500/20 text-amber-800 px-2 py-1 rounded-full font-semibold">
                      Caution
                    </span>
                  </div>
                  <div className="text-sm text-amber-800 font-semibold">
                    {tamilData.yamagandam}
                  </div>
                </div>
              </div>
            </div>

            {/* Current Status - Liquid Glass with Gradient */}
            <div className="glass-header rounded-3xl p-4 text-white shadow-2xl">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-90 mb-1">Current Status</div>
                  <div className="text-lg font-semibold">✨ Amirtha Yogam Active</div>
                  <div className="text-xs opacity-80 mt-1 bg-white/20 inline-block px-2 py-1 rounded-full">
                    1 hour 38 minutes remaining
                  </div>
                </div>
                <div className="text-right floating">
                  <div className="text-4xl font-bold">12:37</div>
                  <div className="text-xs opacity-80">PM</div>
                </div>
              </div>
            </div>

            {/* Data Verification Badge - Glass */}
            <div className="glass-card rounded-3xl p-4 border-2 border-green-200/50">
              <div className="flex items-center gap-3">
                <div className="flex-shrink-0">
                  <div className="w-10 h-10 bg-gradient-to-br from-green-400/30 to-emerald-500/30 backdrop-blur-sm rounded-2xl flex items-center justify-center shadow-lg">
                    <span className="text-lg text-green-700">✓</span>
                  </div>
                </div>
                <div className="flex-1">
                  <div className="text-xs font-semibold text-green-900 mb-1">
                    Verified Panchangam Data
                  </div>
                  <div className="text-[10px] text-gray-600">
                    Calculated using Thirukanitha method • Verified against traditional sources
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Weekly View with Liquid Glass */}
        {view === 'weekly' && (
          <div className="glass-card rounded-3xl p-5 shadow-xl">
            <div className="flex items-center justify-between mb-6">
              <button className="p-2 hover:bg-gray-100/50 rounded-xl transition backdrop-blur-sm">
                <ChevronLeft size={20} className="text-gray-600" />
              </button>
              <h3 className="font-semibold text-gray-900">
                This Week
              </h3>
              <button className="p-2 hover:bg-gray-100/50 rounded-xl transition backdrop-blur-sm">
                <ChevronRight size={20} className="text-gray-600" />
              </button>
            </div>

            <div className="grid grid-cols-7 gap-2 mb-4">
              {weekData.map((day, idx) => (
                <div
                  key={idx}
                  className={`text-center p-3 rounded-2xl transition ${
                    day.isToday
                      ? 'glass-header text-white shadow-xl floating'
                      : day.isAuspicious
                      ? 'glass-card-dark border-2 border-amber-200'
                      : 'glass-card-dark'
                  }`}
                >
                  <div className={`text-xs font-medium mb-1 ${
                    day.isToday ? 'text-white' : 'text-gray-600'
                  }`}>
                    {day.day}
                  </div>
                  <div className={`text-lg font-bold mb-1 ${
                    day.isToday ? 'text-white' : 'text-gray-900'
                  }`}>
                    {day.date}
                  </div>
                  <div className={`text-[10px] ${
                    day.isToday ? 'text-white opacity-80' : 'text-gray-500'
                  }`}>
                    {day.tamilDate}
                  </div>
                  {day.isAuspicious && !day.isToday && (
                    <div className="mt-2">
                      <div className="text-[10px] font-semibold text-amber-700">
                        {day.auspiciousType === 'Ekadasi' ? '🔴' : '🟡'}
                      </div>
                    </div>
                  )}
                  {day.yogam && !day.isToday && (
                    <div className="mt-1">
                      <div className="text-[9px] text-gray-600">
                        {day.yogam === 'Amirtha' ? '✨' : day.yogam === 'Siddha' ? '🌟' : '⚠️'}
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>

            {/* Week Legend */}
            <div className="border-t border-gray-200/50 pt-4 space-y-2">
              <div className="text-xs font-semibold text-gray-700 mb-3">This Week's Overview</div>
              
              <div className="flex items-center gap-3 text-xs flex-wrap">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-gradient-to-br from-orange-400 to-red-500"></div>
                  <span className="text-gray-600">Today</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-gray-300"></div>
                  <span className="text-gray-600">Regular</span>
                </div>
              </div>

              <div className="glass-card-dark rounded-2xl p-3 mt-3 border-l-4 border-amber-400">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-xs font-semibold text-amber-900">Auspicious Days:</span>
                </div>
                <div className="text-xs text-amber-800 space-y-1">
                  <div>• Wed: Pradosham 🟡 (avoid non-veg Tue night)</div>
                  <div>• Fri: Ekadasi 🔴 (avoid non-veg Thu night)</div>
                </div>
              </div>

              <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-green-400">
                <div className="text-xs text-green-800">
                  <span className="font-semibold">💡 Planning Tip:</span> Cook extra veg on Wednesday for Thursday meals
                </div>
              </div>

              {/* Yogam Legend */}
              <div className="glass-card-dark rounded-2xl p-3 border-l-4 border-purple-400">
                <div className="text-xs font-semibold text-purple-900 mb-2">Yogam Indicators:</div>
                <div className="grid grid-cols-3 gap-2 text-[10px] text-purple-800">
                  <div>✨ Amirtha</div>
                  <div>🌟 Siddha</div>
                  <div>⚠️ Marana</div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Bottom Hint */}
        <div className="mt-6 text-center text-xs text-gray-500 backdrop-blur-sm bg-white/30 inline-block px-4 py-2 rounded-full mx-auto block">
          Swipe left/right to navigate • Long press to add events
        </div>
      </div>
    </div>
  );
};

export default TamilCalendarLiquidGlass;
