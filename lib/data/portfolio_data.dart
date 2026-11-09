/// All portfolio content in one place. Work experience and education
/// come from assets/cv.pdf.
abstract final class Portfolio {
  static const name = 'Umesh Chakradhar';
  static const headline = 'Mobile Application Developer & Tech Enthusiast';

  static const stats = <({String value, String label})>[
    (value: '6+', label: 'Years of Experience'),
    (value: '20+', label: 'Projects Worked On'),
    (value: '500k+', label: 'Users Reached'),
  ];

  /// `*text*` is rendered with a highlighter.
  static const about = <String>[
    'Experienced Mobile Application Developer with a strong background '
        'working in a *Fintech company*.',
    'Specialised in building robust, scalable *Offline-First and Online '
        'Mobile Applications* across both *Native Android* (Kotlin, Java, '
        'Android SDKs) and *Hybrid Flutter*.',
    'Engineered production-grade applications that have scaled to *over '
        '500,000 active users*.',
  ];

  static const cvAsset = 'assets/cv.pdf';

  static const experience = <Job>[
    Job(
      company: 'Vanilla Tech Pvt Ltd',
      place: 'Hattisar',
      role: 'Senior Mobile Developer',
      period: 'Jun 2022 - Present',
      points: [
        'Develop and maintain mobile apps for multiple eWallets, airlines '
            'and remittance services.',
        'Built multiple Flutter SDKs and modules (RPP, Remit) and '
            'integrated them into an app with a 400k+ user base.',
        'Unit and integration tests.',
        'CI/CD pipelines (Codemagic, Fastlane, GitHub Actions) for Flutter '
            'projects with native modules.',
      ],
    ),
    Job(
      company: 'Synergy Tech Pvt Ltd',
      place: 'Pulchowk',
      role: 'Mid Level Android Developer (Java)',
      period: 'Aug 2019 - Jun 2022',
      points: [
        'Developed and maintained native Android tablet-banking apps for '
            'microfinance.',
        'Built an inventory application in Flutter.',
        'Printer and fingerprint device integration.',
        'Unit testing for existing features.',
      ],
    ),
    Job(
      company: 'Code Logic Technologies',
      place: 'Buddhanagar',
      role: 'Intern & Junior Android Developer',
      period: 'Apr 2019 - Aug 2019',
      points: [
        'Features and bug fixes in a school management application.',
        'Built a news portal app from scratch as an intern project.',
      ],
    ),
  ];

  static const education = <School>[
    School(
      name: 'KIST College, Kamalpokhari',
      degree: 'Bachelors in Information Technology',
      period: '2015 - 2019',
    ),
    School(
      name: 'DAV SKVB HSS, Jawalakhel',
      degree: '+2 Management',
      period: '2012 - 2014',
    ),
  ];

  static const skills = <String>[
    'Flutter',
    'Dart',
    'Kotlin',
    'Java',
    'Android SDK',
    'Jetpack Compose',
    'Offline-first',
    'REST APIs',
    'Flutter SDKs & Plugins',
    'Firebase',
    'Codemagic',
    'Fastlane',
    'GitHub Actions',
    'Mockito',
    'Espresso',
    'Patrol',
    'Maestro',
  ];

  static const sideProject = (
    name: 'Online College Notes',
    tech: 'Flutter - on Google Play',
    description:
        'Past questions and study notes for students from Class 10 to '
        'Bachelors level, available online and offline.',
  );

  static const languages = 'English, Nepali, Newari, Hindi';

  static const location = 'Thimi, Bhaktapur, Nepal';
  static const phone = '9843661414';
  static const phoneIntl = '+9779843661414';
  static const email = 'umeshchakradhar11@gmail.com';
  static const linkedinShort = 'linkedin.com/in/umesh-chakradhar';

  static const socials = <Social>[
    Social(
      name: 'GitHub',
      handle: '@UmeshChakre',
      url: 'https://github.com/UmeshChakre',
      icon: 'github',
    ),
    Social(
      name: 'LinkedIn',
      handle: 'umesh-chakradhar',
      url: 'https://www.linkedin.com/in/umesh-chakradhar/',
      icon: 'linkedin',
    ),
    Social(
      name: 'Facebook',
      handle: 'umesh.cronaldo7',
      url: 'https://www.facebook.com/umesh.cronaldo7/',
      icon: 'facebook',
    ),
    Social(
      name: 'Instagram',
      handle: '@umesh_chakre',
      url: 'https://www.instagram.com/umesh_chakre/',
      icon: 'instagram',
    ),
  ];

  static const hobbies = <Hobby>[
    Hobby(
      title: 'Football',
      note: 'Die-hard Manchester United fan. Glory Glory!',
      icon: 'ball',
      paper: 0xFFFFF59D,
      tilt: -0.04,
    ),
    Hobby(
      title: 'Movies',
      note: 'Popcorn + a good thriller = perfect weekend.',
      icon: 'film',
      paper: 0xFFB3E5FC,
      tilt: 0.03,
    ),
    Hobby(
      title: 'Music',
      note: 'Headphones on, bugs off.',
      icon: 'note',
      paper: 0xFFF8BBD0,
      tilt: -0.02,
    ),
    Hobby(
      title: 'Online Gaming',
      note: 'One more match. Then I will sleep. Promise.',
      icon: 'gamepad',
      paper: 0xFFC8E6C9,
      tilt: 0.045,
    ),
  ];
}

class Job {
  const Job({
    required this.company,
    required this.place,
    required this.role,
    required this.period,
    required this.points,
  });

  final String company;
  final String place;
  final String role;
  final String period;
  final List<String> points;
}

class School {
  const School({
    required this.name,
    required this.degree,
    required this.period,
  });

  final String name;
  final String degree;
  final String period;
}

class Social {
  const Social({
    required this.name,
    required this.handle,
    required this.url,
    required this.icon,
  });

  final String name;
  final String handle;
  final String url;
  final String icon;
}

class Hobby {
  const Hobby({
    required this.title,
    required this.note,
    required this.icon,
    required this.paper,
    required this.tilt,
  });

  final String title;
  final String note;
  final String icon;
  final int paper;
  final double tilt;
}
