import 'dart:ui';

class ResString {
  var data ={
  'swipe' : 'Swipe and Select',
    'private' : 'Private',
    'public' : 'Public',
    'privateDescription': 'Non-Monetizable Visible to self and friends only',
    'publicDescription': 'Monetizable Visible to the entire network',
    'newPost': 'New Post',
    'travel': 'Travel',
    'food': 'Food',
    'both': 'Both',
    'experience': 'Your Experience',
    'searchtext': 'Search Location',
    'descriptionHintText': 'Description here....',
    'category': 'Category',
    'describe': 'Describe',
    'submitText': 'Submit',
    'appTitle': 'goDach',
    'connectingServer': 'Connection Server....',
    'suceessfulUpload': 'Successfully Upload',
    'successfulDescription': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
    'done': 'Done',
    'descriptionRequired': 'Description Required',
    'placeNameRequired': 'Place Name Required',
    'importimage': 'Import Images/Video',
    'import': 'Import',
    'uploading': 'Uploading',
    'oneimagerequired': 'Atleast one image or video required',
    'appIntroHeadng1':'Discover Experiences',
    'appIntroHeadng2':'Trace your travels',
    'appIntroHeadng3':'Share and Earn',
    'appIntroSubHeading1':'Swipe and Discover novel travel experiences through the eyes of your fellow wanderers.',
    'appIntroSubHeading2':'Store all your travel memories and never miss a chance to relive them.',
    'appIntroSubHeading3':'Share your travel stories and earn amazing rewards.',
    'privacy_policy':'Privacy Policy',
    'term_of_uses':'Term of use'
  };
  String get(String key){
    return data[key];
  }
}

