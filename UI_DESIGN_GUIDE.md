# UI Design Guide - Pastel Skincare App

## Overview
This document defines the exact UI design system for the skincare tracking app, based on the reference image showing a clean, pastel-themed profile page.

## Design Principles

### 1. Color Palette
- **Primary Background**: Pure white (`#FFFFFF`)
- **Card Backgrounds**: Very light pink (`#FEF2F7`)
- **Input Fields**: Very light pastel yellow (`#FFF8E1`)
- **Accent Color**: Light pink (`#F8C8E6`)
- **Text Primary**: Dark gray (`#212121`)
- **Text Secondary**: Light gray (`#757575`)

### 2. Typography
- **Font Family**: Google Fonts Poppins
- **Headings**: Bold (700), 18-22px
- **Body Text**: Medium (500), 14px
- **Captions**: Medium (500), 12px

### 3. Spacing System
- **Page Padding**: 20px
- **Card Padding**: 24px
- **Input Padding**: 16px horizontal, 12px vertical
- **Element Spacing**: 8px, 16px, 24px

### 4. Border Radius
- **Cards**: 20px
- **Input Fields**: 12px
- **Buttons**: 12px
- **Tags**: 12px

## Component Specifications

### Cards
```dart
// Use PastelCard widget for main content
PastelCard(
  padding: EdgeInsets.all(24),
  child: YourContent(),
)
```

### Input Fields
```dart
// Use InputCard widget for input containers
InputCard(
  child: Row(
    children: [
      Icon(Icons.person_outline, color: AppColors.pink),
      SizedBox(width: 12),
      Expanded(child: TextField(...)),
    ],
  ),
)
```

### Shadows
- **Soft Shadow**: 15px blur, 6px offset, light pink color
- **Medium Shadow**: 12px blur, 4px offset, medium pink color
- **Light Shadow**: 8px blur, 2px offset, light pink color

### Profile Picture
- **Shape**: Circle
- **Border**: 2px light pink
- **Shadow**: Medium shadow
- **Size**: 100x100px

### Tags
- **Background**: Pink
- **Text**: White
- **Border Radius**: 12px
- **Padding**: 12px horizontal, 6px vertical

## Layout Guidelines

### 1. Page Structure
- Clean white background
- 20px page padding
- Single column layout
- Proper spacing between sections

### 2. Navigation
- Bottom navigation bar with black background
- Active item highlighted in pink
- Icons and labels for each section

### 3. Content Hierarchy
- Clear section headings
- Consistent card styling
- Proper visual hierarchy with typography

## Implementation Notes

### Required Widgets
1. **PastelCard**: For main content containers
2. **InputCard**: For input field containers
3. **AppStyleGuide**: For consistent styling

### Color Usage
- Always use `AppColors` class
- Use opacity for subtle variations
- Maintain contrast for accessibility

### Shadow System
- Use `AppColors.shadowLight/Medium/Dark`
- Apply shadows to cards and important elements
- Keep shadows subtle and soft

## Consistency Checklist

- [ ] All cards use PastelCard widget
- [ ] All inputs use InputCard widget
- [ ] Colors from AppColors class only
- [ ] Typography from AppStyleGuide
- [ ] Proper spacing (8px, 16px, 24px)
- [ ] Rounded corners (12px for inputs, 20px for cards)
- [ ] Soft shadows applied
- [ ] Clean white backgrounds
- [ ] Mobile-friendly layout
- [ ] Google Fonts Poppins used

## File Structure
```
lib/
├── core/
│   ├── theme.dart          # Color definitions
│   └── style_guide.dart    # Typography and styles
├── widgets/
│   └── common/
│       ├── pastel_card.dart    # Main card widget
│       └── custom_input_field.dart  # Input field widget
└── screens/               # All pages follow this design
```

## Usage Examples

### Profile Page Layout
```dart
Scaffold(
  backgroundColor: AppColors.white,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: AppStyleGuide.pagePadding,
      child: Column(
        children: [
          // Profile Header Card
          PastelCard(
            child: Column(
              children: [
                // Profile Picture
                Container(
                  decoration: AppStyleGuide.profilePictureDecoration,
                  child: Image(...),
                ),
                // Username and Tag
              ],
            ),
          ),
          
          // Personal Information Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kişisel Bilgiler', style: AppStyleGuide.heading3),
              // Input Fields
              InputCard(child: ...),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

This design system ensures consistency across all pages while maintaining the beautiful pastel aesthetic shown in the reference image. 