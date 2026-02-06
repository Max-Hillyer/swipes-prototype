# Swipes

A Swift Student Challenge submission that helps high school students discover summer programs, internships, and experiences through an intuitive swipe-based interface.

## Overview

ProgramSwiper democratizes access to summer opportunities by providing a free, accessible platform for students to explore programs that can transform their college applications and future careers. No expensive counselors required.

## Mission

Every high school student deserves access to amazing summer programs, regardless of their resources or connections. ProgramSwiper makes finding these opportunities simple, free, and accessible to everyone.

## Features

### Swipe-Based Discovery
- **Interface**: Swipe right on programs you love, left on ones that don't fit
- **Rich Program Cards**: View detailed information including location, category, selectivity, application deadlines, duration, restrictions, and cost
- **Visual Feedback**: Smooth animations and gestures make exploring programs engaging and intuitive

### Smart Recommendations
- **Recommendation System**: After just 5 swipes, the app learns from your preferences to suggest programs that match your interests and goals
- **Personalized Experience**: The recommendation system adapts to your swiping patterns, helping you discover programs you're more likely to be interested in

### Save Your Favorites
- **Liked Programs Collection**: All your swiped-right programs are saved in one convenient location
- **Quick Access**: View deadlines, details, and program information whenever you need them

### Track Your Journey
- **Statistics Dashboard**: View insights about your program preferences and swiping patterns
- **Discover Your Interests**: Understand what categories and types of programs you're drawn to as you explore

### Location Integration
- **Offline Location Tracking**: Uses CoreLocation to help you find programs near you
- **Distance Calculations**: See how far programs are from your current location

## Technology Stack
- **SwiftUI**: Modern, declarative UI framework
- **CoreLocation**: Location services and distance calculations
- **UserDefaults**: Persistent storage for liked programs and swipe records
- **CSV Data Parsing**: Program data loaded from curated sources

## App Structure
- **SwipeView**: Main discovery interface with card-based swiping
- **LikedView**: Collection of saved favorite programs
- **StatView**: Analytics and insights dashboard
- **WelcomeView**: Onboarding experience for first-time users
- **RecEngine**: Smart recommendation system that learns from user behavior

