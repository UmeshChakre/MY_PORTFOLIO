import '../desk/window_manager.dart';
import 'about_section.dart';
import 'connect_section.dart';
import 'contact_section.dart';
import 'hero_section.dart';
import 'hobbies_section.dart';

const _site = 'Umesh Chakradhar';

/// The windows on the desk, in layout (reading) order.
const portfolioWindows = <WindowSpec>[
  WindowSpec(
    id: 'hero',
    title: 'Untitled - Paint',
    taskLabel: 'Welcome',
    icon: 'brush',
    fullSpan: true,
    child: HeroSection(),
    pageTitle: '$_site | Mobile Application Developer',
  ),
  WindowSpec(
    id: 'about',
    title: 'about_me.txt',
    taskLabel: 'About',
    icon: 'text',
    child: AboutSection(),
    pageTitle: 'About | $_site',
  ),
  WindowSpec(
    id: 'experience',
    title: 'work_experience.log',
    taskLabel: 'Experience',
    icon: 'floppy',
    child: ExperienceSection(),
    pageTitle: 'Work Experience | $_site',
  ),
  WindowSpec(
    id: 'hobbies',
    title: 'Sketchpad - hobbies.bmp',
    taskLabel: 'Hobbies',
    icon: 'pencil',
    child: HobbiesSection(),
    pageTitle: 'Hobbies | $_site',
  ),
  WindowSpec(
    id: 'education',
    title: 'education.txt',
    taskLabel: 'Education',
    icon: 'note',
    child: EducationSection(),
    pageTitle: 'Education | $_site',
  ),
  WindowSpec(
    id: 'connect',
    title: 'Connect - Tool Box',
    taskLabel: 'Connect',
    icon: 'github',
    child: ConnectSection(),
    pageTitle: 'Connect | $_site',
  ),
  WindowSpec(
    id: 'contact',
    title: 'Send Message.txt - Notepad',
    taskLabel: 'Contact',
    icon: 'mail',
    fullSpan: true,
    child: ContactSection(),
    pageTitle: "Let's Work Together | $_site",
  ),
];
