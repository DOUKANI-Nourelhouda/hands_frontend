import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hands/services/lang_manager.dart';

const Map<String, Map<String, String>> languages = {
  'en': {
    'Home': 'Home',
    'Search': 'Search',
    'Messages': 'Messages',
    'Profile': 'Profile',
    'Settings': 'Settings',
    'Language': 'Language',
    'Choose Language': 'Choose language',
    'English': 'English',
    'French': 'French',
    'Arabic': 'Arabic',
    'Categories': 'Categories',
    'All': 'All',
    'Food': 'Food',
    'Beauty': 'Beauty',
    'Sports': 'Sports',
    'Delivery': 'Delivery',
    'Printing & Copying': 'Printing & Copying',
    'Sewing': 'Sewing',
    'Phone & PC Repair': 'Phone & Pc Repair',
    'Education': 'Education',
    'Design': 'Design',
    'Photography': 'Photography',
    'Video Editing': 'Video Editing',
    'Hairdressing': 'Hairdressing',
    'Cleaning': 'Cleaning',
    'Laundry': 'Laundry',
    'Handmade': 'Handmade',
    'Electronics': 'Electronics',
    'Clothing': 'Clothing',
    'Jewelry': 'Jewerlry',
    'Translation': 'Translation',
    'Projects': 'Projects',
    'Programming': 'Programming',
    'Trips': 'Trips',
    'Lost Found': 'Lost & Found',
    'Rentals Borrowing': 'Rentals & Borrowing',
    'Questions Answers': 'Questions & Answers',
    'Other': 'Other',
    'Cancel': 'Cancel',
    'Save': 'Save',
    'Delete': 'Delete',
    'Report': 'Report',
    'No Posts': 'No posts yet',
    'Search Hint': 'Discover services in your residence',
    'Edit Post': 'Edit post',
    'Delete Post': 'Delete post',
    'Report Post': 'Report post',
    'Block User': 'Block user',
    'Comments': 'Comments',
    'No Comments Yet Be The First!': 'No comments yet. Be the first !',
    'Write A Comment': 'Write a comment',
    'Edit': 'Edit',
    'Reply': 'Reply',
    'No Posts About': 'No posts about',
    'Yet': 'yet',
    'Posts': 'Posts',
    'Users': 'Users',
    'Groups': 'Groups',
    'Create A Post': 'Create a post',
    'Share Your Service With Your Residence!':
        'Share your service with your residence!',
    'Category': 'Category',
    'Caption': 'Caption',
    'Add Photos Or Videos': 'Add photos or videos',
    'Publish Post': 'Publish post',
    'Caption Is Required': 'Caption is required',
    'Search People Or Groups': 'Search people or groups',
    'Direct Messages': 'Direct messages',
    'Group Name': 'Group name',
    'Seach Users': 'Seach Users',
    'Following': 'Following',
    'Followers': 'Followers',
    'Replies': 'Replies',
    'Post Credits': 'Post Credits',
    'Your Balance': 'Your balance',
    'Keep Track Of The Posts You Can Publish':
        'Keep track of the posts you can publish',
    'Free Posts Left': 'Free posts left',
    'Paid Post Credits': 'Paid post credits',
    'Get More Post Credits': 'Get more post credits',
    'Choose The Package That Works For You!':
        'Choose the package that works for you!',
    '5 Post Credits': '5 post credits',
    '50 DA': '50 DA',
    'For Those Who Is Just Getting Started':
        'For Those Who Is Just Getting Started',
    '10 0 DA / Post': '10 0 DA / Post',
    'Buy Package': 'Buy package',
    '10 Post Credits': '10 post credits',
    'For Who Wants To Do More': 'For Who Wants To Do More',
    '90 DA': '90 DA',
    '9 0 DA / Post': '9 0 DA / Post',
    '20 Post Credits': '20 post credits',
    'For Those Who Never Stop Creating': 'For Those Who Never Stop Creating',
    '170 DA': '170 DA',
    '8 5 DA / Post': '8 5 DA / Post',
    'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used':
        'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used',
    'Edit Profile': 'Edit profile',
    'Personal Information': 'Personal information',
    'Username': 'Username',
    'Bio': 'Bio',
    'Location': 'Location',
    'Save Changes': 'Save changes',
    'Update Your Service Details': 'Update your service details',
    'Existing Media': 'Existing media',
    'New Media': 'New media',
    'Followers Following': 'Followers & Following',
    'Remore Follower': 'Remove follower',
    'Followings': 'Following',
    'Are You Sure You Want To Remove': 'Are you sure you want to remove',
    'From Your Followers?': 'from your followers?',
    'Remove': 'Remove',
    'Unfollow User': 'Unfollow user',
    'Are You Sure You Want To Unfollow': 'Are you sure you want to unfollow',
    'Confirm': 'Confirm',
    'Choose Display Mode': 'Choose display mode',
    'Light': 'Light',
    'Dark': 'Dark',
    'Blocked Accounts': 'Blocked accounts',
    'No Blocked Accounts': 'No blocked accounts',
    'Accounts You Block Will Appear Here':
        'Accounts you block will appear here',
    'Unblock Account?': 'Unblock account?',
    'Are You Sure You Want To Unblock': 'Are you sure you want to unblock',
    'Unblock': 'Unblock',
    'Privacy Policy': 'Privacy Policy',
    'Your Privacy Matters': 'Your privacy matters',
    'Learn how Hands handles your information when ':
        'Learn how Hands handles your information when ',
    'You use the app to connect with students and ':
        'You use the app to connect with students and ',
    'Exchange services within your residence.':
        'Exchange services within your residence.',
    '1. Information we collect': '1. Information we collect',
    'Hands may collect information you provide when creating ':
        'Hands may collect information you provide when creating ',
    'Your account, such as your username, email address, ':
        'Your account, such as your username, email address, ',
    'Residence, profile picture, and bio. Content you publish, ':
        'Residence, profile picture, and bio. Content you publish, ',
    'Including posts, comments, and media, may also be stored ':
        'Including posts, comments, and media, may also be stored ',
    'To provide the app services.': 'To provide the app services.',
    '2. Residence-based access': '2. Residence-based access',
    'Hands is designed to connect students within their ':
        'Hands is designed to connect students within their ',
    'Residence. Your residence information is used to help ':
        'Residence. Your residence information is used to help ',
    'Provide residence-based features. This does not mean ':
        'Provide residence-based features. This does not mean ',
    'Every piece of your personal information is visible ':
        'Every piece of your personal information is visible ',
    'To every resident.': 'To every resident.',
    '3. Messages and communication': '3. Messages and communication',
    'Hands allows users to communicate through messages. ':
        'Hands allows users to communicate through messages. ',
    'Messages are intended for the relevant conversation ':
        'Messages are intended for the relevant conversation ',
    'Participants. Do not share passwords, financial details, ':
        'Participants. Do not share passwords, financial details, ',
    'Or other sensitive information in chats. Only describe ':
        'Or other sensitive information in chats. Only describe ',
    'Messages as private or encrypted if the app actually ':
        'Messages as private or encrypted if the app actually ',
    'Provides those protections.': 'Provides those protections.',
    '4. Posts and profile information': '4. Posts and profile information',
    'Information you publish on your profile or in posts may ':
        'Information you publish on your profile or in posts may ',
    'Be visible to other users who are permitted to access it. ':
        'Be visible to other users who are permitted to access it. ',
    'Think carefully before publishing personal details or':
        'Think carefully before publishing personal details or',
    'Uploading photos and videos.': 'Uploading photos and videos.',
    '5. Blocking and reporting': '5. Blocking and reporting',
    'You can use available blocking features to limit ':
        'You can use available blocking features to limit ',
    'Interactions with specific accounts. Reports may be ':
        'Interactions with specific accounts. Reports may be ',
    'Reviewed to help address inappropriate content or ':
        'Reviewed to help address inappropriate content or ',
    'Behavior. Blocking should not be treated as a guarantee ':
        'Behavior. Blocking should not be treated as a guarantee ',
    'That all previous interactions or content are erased.':
        'That all previous interactions or content are erased.',
    '6. Data security': '6. Data security',
    'We use technical and organizational measures intended ':
        'We use technical and organizational measures intended ',
    'To protect account information. No online service can ':
        'To protect account information. No online service can ',
    'Guarantee absolute security. Keep your login credentials ':
        'Guarantee absolute security. Keep your login credentials ',
    'Safe and report suspicious activity.':
        'Safe and report suspicious activity.',
    '7. Storage and service providers': '7. Storage and service providers',
    'Information may be processed by the service providers ':
        'Information may be processed by the service providers ',
    'Needed to operate Hands, such as database, media storage, ':
        'Needed to operate Hands, such as database, media storage, ',
    'Authentication, and payment providers, where applicable. ':
        'Authentication, and payment providers, where applicable. ',
    'The final policy should identify the providers actually ':
        'The final policy should identify the providers actually ',
    'Used and explain their relevant roles.':
        'Used and explain their relevant roles.',
    '8. Your choices and your data': '8. Your choices and your data',
    'You can manage information through the settings and ':
        'You can manage information through the settings and ',
    'Features available in Hands. You may request access to, ':
        'Features available in Hands. You may request access to, ',
    'Correction of, or deletion of your personal information, ':
        'Correction of, or deletion of your personal information, ',
    'Subject to applicable law and legitimate retention ':
        'Subject to applicable law and legitimate retention ',
    'Requirements. Add your actual account-deletion process ':
        'Requirements. Add your actual account-deletion process ',
    'And contact details before publishing this policy.':
        'And contact details before publishing this policy.',
    '9. Age requirements': '9. Age requirements',
    'Hands is intended for its eligible student audience. ':
        'Hands is intended for its eligible student audience. ',
    'The app should apply and communicate its actual minimum ':
        'The app should apply and communicate its actual minimum ',
    'Age requirements and comply with the laws applicable ':
        'Age requirements and comply with the laws applicable ',
    'To its users.': 'To its users.',
    '10. Changes to this policy': '10. Changes to this policy',
    'This policy may be updated when Hands changes its ':
        'This policy may be updated when Hands changes its ',
    'Features or legal requirements change. When appropriate, ':
        'Features or legal requirements change. When appropriate, ',
    'Users will be informed of significant changes.':
        'Users will be informed of significant changes.',
    '11. Contact us': '11. Contact us',
    'For questions about this policy or your personal ':
        'For questions about this policy or your personal ',
    'Information, contact the Hands team at the official ':
        'Information, contact the Hands team at the official ',
    'Privacy email address published by the app developer.':
        'Privacy email address published by the app developer.',
    'Draft for review — add the effective date and ':
        'Draft for review — add the effective date and ',
    'Verified contact details before publication.':
        'Verified contact details before publication.',
    'Terms Of Service': 'Terms of Service',
    'Welcome to Hands!': 'Welcome to Hands!',
    'Hands connects students living in the ':
        'Hands connects students living in the ',
    'Same residence to share services, ': 'Same residence to share services, ',
    'Offer skills, and help each other.': 'Offer skills, and help each other.',
    '1. Acceptance of Terms': '1. Acceptance of Terms',
    'By creating an account or using Hands, you agree ':
        'By creating an account or using Hands, you agree ',
    'To follow these Terms of Service and applicable ':
        'To follow these Terms of Service and applicable ',
    'Laws. If you do not agree, please stop using ':
        'Laws. If you do not agree, please stop using ',
    'The platform.': 'The platform.',
    '2. Eligibility and Accounts': '2. Eligibility and Accounts',
    'Hands is designed for students within participating ':
        'Hands is designed for students within participating ',
    'Student residences. You must provide accurate ':
        'Student residences. You must provide accurate ',
    'Information, keep your account credentials secure, ':
        'Information, keep your account credentials secure, ',
    'And not impersonate another person or create ':
        'And not impersonate another person or create ',
    'Fraudulent accounts.': 'Fraudulent accounts.',
    '3. Posts and Services': '3. Posts and Services',
    'You are responsible for the content you publish ':
        'You are responsible for the content you publish ',
    'And the services you offer. Posts must be accurate, ':
        'And the services you offer. Posts must be accurate, ',
    'Respectful, and lawful. Do not publish misleading ':
        'Respectful, and lawful. Do not publish misleading ',
    'Offers, prohibited content, spam, or services ':
        'Offers, prohibited content, spam, or services ',
    'That could endanger other students.':
        'That could endanger other students.',
    '4. Communication and Conduct': '4. Communication and Conduct',
    'Treat other users respectfully. Harassment, threats, ':
        'Treat other users respectfully. Harassment, threats, ',
    'Fraud, discrimination, impersonation, and misuse ':
        'Fraud, discrimination, impersonation, and misuse ',
    'Of private information are not permitted. You may ':
        'Of private information are not permitted. You may ',
    'Block or report users who violate these rules.':
        'Block or report users who violate these rules.',
    '5. Transactions and Payments': '5. Transactions and Payments',
    'Users are responsible for agreeing on service ':
        'Users are responsible for agreeing on service ',
    'Details, prices, delivery, and payment arrangements. ':
        'Details, prices, delivery, and payment arrangements. ',
    'Hands does not guarantee the quality, completion, ':
        'Hands does not guarantee the quality, completion, ',
    'Or outcome of services offered by other users. ':
        'Or outcome of services offered by other users. ',
    'Any paid post-credit purchases are subject to ':
        'Any paid post-credit purchases are subject to ',
    'The prices and conditions displayed at purchase.':
        'The prices and conditions displayed at purchase.',
    '6. Free Posts and Paid Credits': '6. Free Posts and Paid Credits',
    'Hands may provide a limited number of free posts ':
        'Hands may provide a limited number of free posts ',
    'And offer additional posting credits for purchase. ':
        'And offer additional posting credits for purchase. ',
    'Available allowances, prices, and applicable ':
        'Available allowances, prices, and applicable ',
    'Conditions will be displayed in the app. Do not ':
        'Conditions will be displayed in the app. Do not ',
    'Attempt to bypass posting limits or manipulate ':
        'Attempt to bypass posting limits or manipulate ',
    'Payment confirmations.': 'Payment confirmations.',
    '7. Privacy and Safety': '7. Privacy and Safety',
    'Use other students’ personal information only ':
        'Use other students’ personal information only ',
    'For legitimate purposes related to the platform. ':
        'For legitimate purposes related to the platform. ',
    'Do not share private messages, contact details, ':
        'Do not share private messages, contact details, ',
    'Or other personal information without appropriate':
        'Or other personal information without appropriate',
    'Permission. Review our Privacy Policy to understand ':
        'Permission. Review our Privacy Policy to understand ',
    'How personal information is handled.':
        'How personal information is handled.',
    '8. Reporting and Account Restrictions':
        '8. Reporting and Account Restrictions',
    'Hands may review reported content and take ':
        'Hands may review reported content and take ',
    'Appropriate action against accounts that violate ':
        'Appropriate action against accounts that violate ',
    'These terms, including removing posts, restricting ':
        'These terms, including removing posts, restricting ',
    'Features, or suspending accounts, where appropriate.':
        'Features, or suspending accounts, where appropriate.',
    '9. Service Availability': '9. Service Availability',
    'We aim to keep Hands available and functioning ':
        'We aim to keep Hands available and functioning ',
    'Properly, but uninterrupted access is not ':
        'Properly, but uninterrupted access is not ',
    'Guaranteed. Features may be updated, changed, ':
        'Guaranteed. Features may be updated, changed, ',
    'Or temporarily unavailable.': 'Or temporarily unavailable.',
    '10. Changes to These Terms': '10. Changes to These Terms',
    'These terms may be updated as Hands evolves. ':
        'These terms may be updated as Hands evolves. ',
    'Material changes should be communicated through ':
        'Material changes should be communicated through ',
    'Appropriate channels. Continued use after updated ':
        'Appropriate channels. Continued use after updated ',
    'Terms take effect may be subject to those terms, ':
        'Terms take effect may be subject to those terms, ',
    'As permitted by applicable law.': 'As permitted by applicable law.',
    '11. Contact Us': '11. Contact Us',
    'If you have questions about these terms, contact ':
        'If you have questions about these terms, contact ',
    'The Hands team through the official support ':
        'The Hands team through the official support ',
    'Channel provided in the app.': 'Channel provided in the app.',
    'Help Support': 'Help & Support',
    'How can we help you?': 'How can we help you?',
    'Find answers to common questions or ':
        'Find answers to common questions or ',
    'Get help with your Hands account.': 'Get help with your Hands account.',
    'Frequently asked questions': 'Frequently asked questions',
    'What is Hands?': 'What is Hands?',
    'Hands is a social marketplace designed for students living ':
        'Hands is a social marketplace designed for students living ',
    'In the same residence. It combines social media features ':
        'In the same residence. It combines social media features ',
    'With a platform where students can offer services, discover ':
        'With a platform where students can offer services, discover ',
    'What others provide, connect through messages, and support ':
        'What others provide, connect through messages, and support ',
    'Their student community.': 'Their student community.',
    'Why can I only see certain posts?': 'Why can I only see certain posts?',
    'Posts are intended for students in your residence. ':
        'Posts are intended for students in your residence. ',
    'Make sure your account is associated with the ':
        'Make sure your account is associated with the ',
    'Correct residence.': 'Correct residence.',
    'How can I publish a post?': 'How can I publish a post?',
    'Open the create-post screen, add your service ':
        'Open the create-post screen, add your service ',
    'Details and media, then follow the instructions ':
        'Details and media, then follow the instructions ',
    'To publish. Posting allowances and any applicable ':
        'To publish. Posting allowances and any applicable ',
    'Credit requirements are shown in the app. ':
        'Credit requirements are shown in the app. ',
    'Why can’t I publish another post?': 'Why can’t I publish another post?',
    'You may have used your free posting allowance ':
        'You may have used your free posting allowance ',
    'And may need additional post credits. Check the ':
        'And may need additional post credits. Check the ',
    'Credits section in your profile.': 'Credits section in your profile.',
    'How do I block or report someone?': 'How do I block or report someone?',
    'Open the relevant profile or post and use the ':
        'Open the relevant profile or post and use the ',
    'Available block or report option. If someone ':
        'Available block or report option. If someone ',
    'Makes you feel unsafe, avoid sharing personal ':
        'Makes you feel unsafe, avoid sharing personal ',
    'Information and contact support.': 'Information and contact support.',
    'How can I edit my profile?': 'How can I edit my profile?',
    'Open your profile and use the available profile ':
        'Open your profile and use the available profile ',
    'Editing option to update your username, bio, ':
        'Editing option to update your username, bio, ',
    'Or profile picture.': 'Or profile picture.',
    'Still need help?': 'Still need help?',
    'Choose an option below to get assistance.':
        'Choose an option below to get assistance.',
    'Log Out?': 'Log out?',
    'Are you sure you want to log out of your Hands account?':
        'Are you sure you want to log out of your Hands account?',
    'Cancle': 'Cancle',
    'Log out': 'Log out',
    'Delete account?': 'Delete account?',
    'Are you sure you want to permanently ':
        'Are you sure you want to permanently ',
    'Delete your Hands account? This action ':
        'Delete your Hands account? This action ',
    'Cannot be undone.': 'Cannot be undone.',
    'No posts yet. Be the first who post!':
        'No posts yet. Be the first who post!',
    'No posts yet': 'No posts yet',
    'No posts found for ': 'No posts found for ',
    'Send message': 'Send message',
    'Share profile': 'Share profile',
    'Block account': 'Block account',
    'Report account': 'Report account',
  },
  'fr': {
    'Home': 'Accueil',
    'Search': 'Rechercher',
    'Messages': 'Messages',
    'Profile': 'Profil',
    'Settings': 'Paramètres',
    'Language': 'Langue',
    'Choose Language': 'Choisir la langue',
    'English': 'Anglais',
    'French': 'Français',
    'Arabic': 'Arabe',
    'Categories': 'Catégories',
    'All': 'Tout',
    'Food': 'Nourriture',
    'Beauty': 'Beauté',
    'Sports': 'Sport',
    'Delivery': 'Livraison',
    'Printing & Copying': 'Impression et photocopie',
    'Sewing': 'Couture',
    'Phone & PC Repair': 'Réparation de téléphones et PC',
    'Education': 'Éducation',
    'Design': 'Design',
    'Photography': 'Photographie',
    'Video Editing': 'Montage vidéo',
    'Hairdressing': 'Coiffure',
    'Cleaning': 'Nettoyage',
    'Laundry': 'Lessive',
    'Handmade': 'Fait main',
    'Electronics': 'Électronique',
    'Clothing': 'Vêtements',
    'Jewelry': 'Bijoux',
    'Translation': 'Traduction',
    'Projects': 'Projets',
    'Programming': 'Programmation',
    'Trips': 'Sorties',
    'Lost Found': 'Objets perdus et trouvés',
    'Rentals Borrowing': 'Location et emprunt',
    'Questions Answers': 'Questions et réponses',
    'Other': 'Autre',
    'Cancel': 'Annuler',
    'Save': 'Enregistrer',
    'Delete': 'Supprimer',
    'Report': 'Signaler',
    'No Posts': 'Aucune publication pour le moment',
    'Search Hint': 'Découvrez les services de votre résidence',
    'Edit Post': 'Modifier la publication',
    'Delete Post': 'Supprimer la publication',
    'Report Post': 'Signaler la publication',
    'Block User': 'Bloquer l’utilisateur',
    'Comments': 'Commentaires',
    'No Comments Yet Be The First!':
        'Aucun commentaire pour le moment. Soyez le premier !',
    'Write A Comment': 'Écrire un commentaire',
    'Edit': 'Modifier',
    'Reply': 'Répondre',
    'No Posts About': 'No posts about',
    'Yet': 'encore',
    'Posts': 'Publications',
    'Users': 'Utilisateurs',
    'Groups': 'Groupes',
    'Create A Post': 'Créer une publication',
    'Share Your Service With Your Residence!':
        'Partagez votre service avec votre résidence !',
    'Category': 'Catégorie',
    'Caption': 'Description',
    'Add Photos Or Videos': 'Ajouter des photos ou des vidéos',
    'Publish Post': 'Publier',
    'Caption Is Required': 'La description est obligatoire',
    'Search People Or Groups': 'Rechercher des personnes ou des groupes',
    'Direct Messages': 'Messages privés',
    'Group Name': 'Nom du groupe',
    'Seach Users': 'Seach Users',
    'Following': 'Abonnements',
    'Followers': 'Abonnés',
    'Replies': 'Réponses',
    'Post Credits': 'Crédits de publication',
    'Your Balance': 'Votre solde',
    'Keep Track Of The Posts You Can Publish':
        'Suivez le nombre de publications que vous pouvez publier',
    'Free Posts Left': 'Publications gratuites restantes',
    'Paid Post Credits': 'Crédits de publication payants',
    'Get More Post Credits': 'Obtenir plus de crédits',
    'Choose The Package That Works For You!':
        'Choisissez le forfait qui vous convient !',
    '5 Post Credits': '5 crédits de publication',
    '50 DA': '50 DA',
    'For Those Who Is Just Getting Started':
        'For Those Who Is Just Getting Started',
    '10 0 DA / Post': '10 0 DA / Post',
    'Buy Package': 'Acheter le forfait',
    '10 Post Credits': '10 crédits de publication',
    'For Who Wants To Do More': 'For Who Wants To Do More',
    '90 DA': '90 DA',
    '9 0 DA / Post': '9 0 DA / Post',
    '20 Post Credits': '20 crédits de publication',
    'For Those Who Never Stop Creating': 'For Those Who Never Stop Creating',
    '170 DA': '170 DA',
    '8 5 DA / Post': '8 5 DA / Post',
    'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used':
        'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used',
    'Edit Profile': 'Modifier le profil',
    'Personal Information': 'Informations personnelles',
    'Username': 'Nom d’utilisateur',
    'Bio': 'Biographie',
    'Location': 'Localisation',
    'Save Changes': 'Enregistrer les modifications',
    'Update Your Service Details': 'Mettez à jour les détails de votre service',
    'Existing Media': 'Médias existants',
    'New Media': 'Nouveaux médias',
    'Followers Following': 'Abonnés et abonnements',
    'Remore Follower': 'Retirer un abonné',
    'Followings': 'Abonnements',
    'Are You Sure You Want To Remove': 'Voulez-vous vraiment retirer',
    'From Your Followers?': 'de vos abonnés ?',
    'Remove': 'Retirer',
    'Unfollow User': 'Se désabonner',
    'Are You Sure You Want To Unfollow':
        'Voulez-vous vraiment vous désabonner de',
    'Confirm': 'Confirmer',
    'Choose Display Mode': 'Choisir le mode d’affichage',
    'Light': 'Clair',
    'Dark': 'Sombre',
    'Blocked Accounts': 'Comptes bloqués',
    'No Blocked Accounts': 'Aucun compte bloqué',
    'Accounts You Block Will Appear Here':
        'Les comptes que vous bloquez apparaîtront ici',
    'Unblock Account?': 'Débloquer ce compte ?',
    'Are You Sure You Want To Unblock': 'Voulez-vous vraiment débloquer',
    'Unblock': 'Débloquer',
    'Privacy Policy': 'Politique de confidentialité',
    'Your Privacy Matters': 'Votre vie privée compte',
    'Learn how Hands handles your information when ':
        'Learn how Hands handles your information when ',
    'You use the app to connect with students and ':
        'You use the app to connect with students and ',
    'Exchange services within your residence.':
        'Exchange services within your residence.',
    '1. Information we collect': '1. Information we collect',
    'Hands may collect information you provide when creating ':
        'Hands may collect information you provide when creating ',
    'Your account, such as your username, email address, ':
        'Your account, such as your username, email address, ',
    'Residence, profile picture, and bio. Content you publish, ':
        'Residence, profile picture, and bio. Content you publish, ',
    'Including posts, comments, and media, may also be stored ':
        'Including posts, comments, and media, may also be stored ',
    'To provide the app services.': 'To provide the app services.',
    '2. Residence-based access': '2. Residence-based access',
    'Hands is designed to connect students within their ':
        'Hands is designed to connect students within their ',
    'Residence. Your residence information is used to help ':
        'Residence. Your residence information is used to help ',
    'Provide residence-based features. This does not mean ':
        'Provide residence-based features. This does not mean ',
    'Every piece of your personal information is visible ':
        'Every piece of your personal information is visible ',
    'To every resident.': 'To every resident.',
    '3. Messages and communication': '3. Messages and communication',
    'Hands allows users to communicate through messages. ':
        'Hands allows users to communicate through messages. ',
    'Messages are intended for the relevant conversation ':
        'Messages are intended for the relevant conversation ',
    'Participants. Do not share passwords, financial details, ':
        'Participants. Do not share passwords, financial details, ',
    'Or other sensitive information in chats. Only describe ':
        'Or other sensitive information in chats. Only describe ',
    'Messages as private or encrypted if the app actually ':
        'Messages as private or encrypted if the app actually ',
    'Provides those protections.': 'Provides those protections.',
    '4. Posts and profile information': '4. Posts and profile information',
    'Information you publish on your profile or in posts may ':
        'Information you publish on your profile or in posts may ',
    'Be visible to other users who are permitted to access it. ':
        'Be visible to other users who are permitted to access it. ',
    'Think carefully before publishing personal details or':
        'Think carefully before publishing personal details or',
    'Uploading photos and videos.': 'Uploading photos and videos.',
    '5. Blocking and reporting': '5. Blocking and reporting',
    'You can use available blocking features to limit ':
        'You can use available blocking features to limit ',
    'Interactions with specific accounts. Reports may be ':
        'Interactions with specific accounts. Reports may be ',
    'Reviewed to help address inappropriate content or ':
        'Reviewed to help address inappropriate content or ',
    'Behavior. Blocking should not be treated as a guarantee ':
        'Behavior. Blocking should not be treated as a guarantee ',
    'That all previous interactions or content are erased.':
        'That all previous interactions or content are erased.',
    '6. Data security': '6. Data security',
    'We use technical and organizational measures intended ':
        'We use technical and organizational measures intended ',
    'To protect account information. No online service can ':
        'To protect account information. No online service can ',
    'Guarantee absolute security. Keep your login credentials ':
        'Guarantee absolute security. Keep your login credentials ',
    'Safe and report suspicious activity.':
        'Safe and report suspicious activity.',
    '7. Storage and service providers': '7. Storage and service providers',
    'Information may be processed by the service providers ':
        'Information may be processed by the service providers ',
    'Needed to operate Hands, such as database, media storage, ':
        'Needed to operate Hands, such as database, media storage, ',
    'Authentication, and payment providers, where applicable. ':
        'Authentication, and payment providers, where applicable. ',
    'The final policy should identify the providers actually ':
        'The final policy should identify the providers actually ',
    'Used and explain their relevant roles.':
        'Used and explain their relevant roles.',
    '8. Your choices and your data': '8. Your choices and your data',
    'You can manage information through the settings and ':
        'You can manage information through the settings and ',
    'Features available in Hands. You may request access to, ':
        'Features available in Hands. You may request access to, ',
    'Correction of, or deletion of your personal information, ':
        'Correction of, or deletion of your personal information, ',
    'Subject to applicable law and legitimate retention ':
        'Subject to applicable law and legitimate retention ',
    'Requirements. Add your actual account-deletion process ':
        'Requirements. Add your actual account-deletion process ',
    'And contact details before publishing this policy.':
        'And contact details before publishing this policy.',
    '9. Age requirements': '9. Age requirements',
    'Hands is intended for its eligible student audience. ':
        'Hands is intended for its eligible student audience. ',
    'The app should apply and communicate its actual minimum ':
        'The app should apply and communicate its actual minimum ',
    'Age requirements and comply with the laws applicable ':
        'Age requirements and comply with the laws applicable ',
    'To its users.': 'To its users.',
    '10. Changes to this policy': '10. Changes to this policy',
    'This policy may be updated when Hands changes its ':
        'This policy may be updated when Hands changes its ',
    'Features or legal requirements change. When appropriate, ':
        'Features or legal requirements change. When appropriate, ',
    'Users will be informed of significant changes.':
        'Users will be informed of significant changes.',
    '11. Contact us': '11. Contact us',
    'For questions about this policy or your personal ':
        'For questions about this policy or your personal ',
    'Information, contact the Hands team at the official ':
        'Information, contact the Hands team at the official ',
    'Privacy email address published by the app developer.':
        'Privacy email address published by the app developer.',
    'Draft for review — add the effective date and ':
        'Draft for review — add the effective date and ',
    'Verified contact details before publication.':
        'Verified contact details before publication.',
    'Terms Of Service': 'Terms of Service',
    'Welcome to Hands!': 'Bienvenue sur Hands !',
    'Hands connects students living in the ':
        'Hands connects students living in the ',
    'Same residence to share services, ': 'Same residence to share services, ',
    'Offer skills, and help each other.': 'Offer skills, and help each other.',
    '1. Acceptance of Terms': '1. Acceptance of Terms',
    'By creating an account or using Hands, you agree ':
        'By creating an account or using Hands, you agree ',
    'To follow these Terms of Service and applicable ':
        'To follow these Terms of Service and applicable ',
    'Laws. If you do not agree, please stop using ':
        'Laws. If you do not agree, please stop using ',
    'The platform.': 'The platform.',
    '2. Eligibility and Accounts': '2. Eligibility and Accounts',
    'Hands is designed for students within participating ':
        'Hands is designed for students within participating ',
    'Student residences. You must provide accurate ':
        'Student residences. You must provide accurate ',
    'Information, keep your account credentials secure, ':
        'Information, keep your account credentials secure, ',
    'And not impersonate another person or create ':
        'And not impersonate another person or create ',
    'Fraudulent accounts.': 'Fraudulent accounts.',
    '3. Posts and Services': '3. Posts and Services',
    'You are responsible for the content you publish ':
        'You are responsible for the content you publish ',
    'And the services you offer. Posts must be accurate, ':
        'And the services you offer. Posts must be accurate, ',
    'Respectful, and lawful. Do not publish misleading ':
        'Respectful, and lawful. Do not publish misleading ',
    'Offers, prohibited content, spam, or services ':
        'Offers, prohibited content, spam, or services ',
    'That could endanger other students.':
        'That could endanger other students.',
    '4. Communication and Conduct': '4. Communication and Conduct',
    'Treat other users respectfully. Harassment, threats, ':
        'Treat other users respectfully. Harassment, threats, ',
    'Fraud, discrimination, impersonation, and misuse ':
        'Fraud, discrimination, impersonation, and misuse ',
    'Of private information are not permitted. You may ':
        'Of private information are not permitted. You may ',
    'Block or report users who violate these rules.':
        'Block or report users who violate these rules.',
    '5. Transactions and Payments': '5. Transactions and Payments',
    'Users are responsible for agreeing on service ':
        'Users are responsible for agreeing on service ',
    'Details, prices, delivery, and payment arrangements. ':
        'Details, prices, delivery, and payment arrangements. ',
    'Hands does not guarantee the quality, completion, ':
        'Hands does not guarantee the quality, completion, ',
    'Or outcome of services offered by other users. ':
        'Or outcome of services offered by other users. ',
    'Any paid post-credit purchases are subject to ':
        'Any paid post-credit purchases are subject to ',
    'The prices and conditions displayed at purchase.':
        'The prices and conditions displayed at purchase.',
    '6. Free Posts and Paid Credits': '6. Free Posts and Paid Credits',
    'Hands may provide a limited number of free posts ':
        'Hands may provide a limited number of free posts ',
    'And offer additional posting credits for purchase. ':
        'And offer additional posting credits for purchase. ',
    'Available allowances, prices, and applicable ':
        'Available allowances, prices, and applicable ',
    'Conditions will be displayed in the app. Do not ':
        'Conditions will be displayed in the app. Do not ',
    'Attempt to bypass posting limits or manipulate ':
        'Attempt to bypass posting limits or manipulate ',
    'Payment confirmations.': 'Payment confirmations.',
    '7. Privacy and Safety': '7. Privacy and Safety',
    'Use other students’ personal information only ':
        'Use other students’ personal information only ',
    'For legitimate purposes related to the platform. ':
        'For legitimate purposes related to the platform. ',
    'Do not share private messages, contact details, ':
        'Do not share private messages, contact details, ',
    'Or other personal information without appropriate':
        'Or other personal information without appropriate',
    'Permission. Review our Privacy Policy to understand ':
        'Permission. Review our Privacy Policy to understand ',
    'How personal information is handled.':
        'How personal information is handled.',
    '8. Reporting and Account Restrictions':
        '8. Reporting and Account Restrictions',
    'Hands may review reported content and take ':
        'Hands may review reported content and take ',
    'Appropriate action against accounts that violate ':
        'Appropriate action against accounts that violate ',
    'These terms, including removing posts, restricting ':
        'These terms, including removing posts, restricting ',
    'Features, or suspending accounts, where appropriate.':
        'Features, or suspending accounts, where appropriate.',
    '9. Service Availability': '9. Service Availability',
    'We aim to keep Hands available and functioning ':
        'We aim to keep Hands available and functioning ',
    'Properly, but uninterrupted access is not ':
        'Properly, but uninterrupted access is not ',
    'Guaranteed. Features may be updated, changed, ':
        'Guaranteed. Features may be updated, changed, ',
    'Or temporarily unavailable.': 'Or temporarily unavailable.',
    '10. Changes to These Terms': '10. Changes to These Terms',
    'These terms may be updated as Hands evolves. ':
        'These terms may be updated as Hands evolves. ',
    'Material changes should be communicated through ':
        'Material changes should be communicated through ',
    'Appropriate channels. Continued use after updated ':
        'Appropriate channels. Continued use after updated ',
    'Terms take effect may be subject to those terms, ':
        'Terms take effect may be subject to those terms, ',
    'As permitted by applicable law.': 'As permitted by applicable law.',
    '11. Contact Us': '11. Contact Us',
    'If you have questions about these terms, contact ':
        'If you have questions about these terms, contact ',
    'The Hands team through the official support ':
        'The Hands team through the official support ',
    'Channel provided in the app.': 'Channel provided in the app.',
    'Help Support': 'Aide et assistance',
    'How can we help you?': 'Comment pouvons-nous vous aider ?',
    'Find answers to common questions or ':
        'Trouvez des réponses aux questions fréquentes ou ',
    'Get help with your Hands account.': 'Get help with your Hands account.',
    'Frequently asked questions': 'Questions fréquentes',
    'What is Hands?': 'Qu’est-ce que Hands ?',
    'Hands is a social marketplace designed for students living ':
        'Hands is a social marketplace designed for students living ',
    'In the same residence. It combines social media features ':
        'In the same residence. It combines social media features ',
    'With a platform where students can offer services, discover ':
        'With a platform where students can offer services, discover ',
    'What others provide, connect through messages, and support ':
        'What others provide, connect through messages, and support ',
    'Their student community.': 'Their student community.',
    'Why can I only see certain posts?':
        'Pourquoi ne vois-je que certaines publications ?',
    'Posts are intended for students in your residence. ':
        'Posts are intended for students in your residence. ',
    'Make sure your account is associated with the ':
        'Make sure your account is associated with the ',
    'Correct residence.': 'Correct residence.',
    'How can I publish a post?': 'Comment publier une publication ?',
    'Open the create-post screen, add your service ':
        'Open the create-post screen, add your service ',
    'Details and media, then follow the instructions ':
        'Details and media, then follow the instructions ',
    'To publish. Posting allowances and any applicable ':
        'To publish. Posting allowances and any applicable ',
    'Credit requirements are shown in the app. ':
        'Credit requirements are shown in the app. ',
    'Why can’t I publish another post?':
        'Pourquoi ne puis-je pas publier à nouveau ?',
    'You may have used your free posting allowance ':
        'You may have used your free posting allowance ',
    'And may need additional post credits. Check the ':
        'And may need additional post credits. Check the ',
    'Credits section in your profile.': 'Credits section in your profile.',
    'How do I block or report someone?':
        'Comment bloquer ou signaler quelqu’un ?',
    'Open the relevant profile or post and use the ':
        'Open the relevant profile or post and use the ',
    'Available block or report option. If someone ':
        'Available block or report option. If someone ',
    'Makes you feel unsafe, avoid sharing personal ':
        'Makes you feel unsafe, avoid sharing personal ',
    'Information and contact support.': 'Information and contact support.',
    'How can I edit my profile?': 'Comment modifier mon profil ?',
    'Open your profile and use the available profile ':
        'Open your profile and use the available profile ',
    'Editing option to update your username, bio, ':
        'Editing option to update your username, bio, ',
    'Or profile picture.': 'Or profile picture.',
    'Still need help?': 'Besoin d’aide supplémentaire ?',
    'Choose an option below to get assistance.':
        'Choisissez une option ci-dessous pour obtenir de l’aide.',
    'Log Out?': 'Log out?',
    'Are you sure you want to log out of your Hands account?':
        'Voulez-vous vraiment vous déconnecter de votre compte Hands ?',
    'Cancle': 'Cancle',
    'Log out': 'Se déconnecter',
    'Delete account?': 'Supprimer le compte ?',
    'Are you sure you want to permanently ':
        'Voulez-vous vraiment supprimer définitivement ',
    'Delete your Hands account? This action ':
        'Delete your Hands account? This action ',
    'Cannot be undone.': 'Cannot be undone.',
    'No posts yet. Be the first who post!':
        'Aucune publication pour le moment. Soyez le premier à publier !',
    'No posts yet': 'Aucune publication pour le moment',
    'No posts found for ': 'Aucune publication trouvée pour ',
    'Send message': 'Envoyer un message',
    'Share profile': 'Partager le profil',
    'Block account': 'Bloquer le compte',
    'Report account': 'Signaler le compte',
  },
  'ar': {
    'Home': 'الرئيسية',
    'Search': 'البحث',
    'Messages': 'الرسائل',
    'Profile': 'الملف الشخصي',
    'Settings': 'الإعدادات',
    'Language': 'اللغة',
    'Choose Language': 'اختر اللغة',
    'English': 'الإنجليزية',
    'French': 'الفرنسية',
    'Arabic': 'العربية',
    'Categories': 'الفئات',
    'All': 'الكل',
    'Food': 'الطعام',
    'Beauty': 'الجمال',
    'Sports': 'الرياضة',
    'Delivery': 'التوصيل',
    'Printing & Copying': 'الطباعة والنسخ',
    'Sewing': 'الخياطة',
    'Phone & PC Repair': 'إصلاح الهواتف والحواسيب',
    'Education': 'التعليم',
    'Design': 'التصميم',
    'Photography': 'التصوير',
    'Video Editing': 'مونتاج الفيديو',
    'Hairdressing': 'تصفيف الشعر',
    'Cleaning': 'التنظيف',
    'Laundry': 'غسل الملابس',
    'Handmade': 'منتجات يدوية',
    'Electronics': 'الإلكترونيات',
    'Clothing': 'الملابس',
    'Jewelry': 'المجوهرات',
    'Translation': 'الترجمة',
    'Projects': 'المشاريع',
    'Programming': 'البرمجة',
    'Trips': 'الرحلات',
    'Lost Found': 'المفقودات والموجودات',
    'Rentals Borrowing': 'الكراء والاستعارة',
    'Questions Answers': 'الأسئلة والأجوبة',
    'Other': 'أخرى',
    'Cancel': 'إلغاء',
    'Save': 'حفظ',
    'Delete': 'حذف',
    'Report': 'إبلاغ',
    'No Posts': 'لا توجد منشورات بعد',
    'Search Hint': 'اكتشف الخدمات في إقامتك الجامعية',
    'Edit Post': 'تعديل المنشور',
    'Delete Post': 'حذف المنشور',
    'Report Post': 'الإبلاغ عن المنشور',
    'Block User': 'حظر المستخدم',
    'Comments': 'التعليقات',
    'No Comments Yet Be The First!': 'لا توجد تعليقات بعد. كن أول من يعلّق!',
    'Write A Comment': 'اكتب تعليقًا',
    'Edit': 'تعديل',
    'Reply': 'رد',
    'No Posts About': 'No posts about',
    'Yet': 'بعد',
    'Posts': 'المنشورات',
    'Users': 'المستخدمون',
    'Groups': 'المجموعات',
    'Create A Post': 'إنشاء منشور',
    'Share Your Service With Your Residence!':
        'شارك خدمتك مع المقيمين في إقامتك!',
    'Category': 'الفئة',
    'Caption': 'الوصف',
    'Add Photos Or Videos': 'أضف صورًا أو مقاطع فيديو',
    'Publish Post': 'نشر المنشور',
    'Caption Is Required': 'الوصف مطلوب',
    'Search People Or Groups': 'ابحث عن أشخاص أو مجموعات',
    'Direct Messages': 'الرسائل المباشرة',
    'Group Name': 'اسم المجموعة',
    'Seach Users': 'Seach Users',
    'Following': 'أتابعهم',
    'Followers': 'المتابعون',
    'Replies': 'الردود',
    'Post Credits': 'رصيد المنشورات',
    'Your Balance': 'رصيدك',
    'Keep Track Of The Posts You Can Publish':
        'تابع عدد المنشورات التي يمكنك نشرها',
    'Free Posts Left': 'المنشورات المجانية المتبقية',
    'Paid Post Credits': 'رصيد المنشورات المدفوع',
    'Get More Post Credits': 'احصل على رصيد إضافي',
    'Choose The Package That Works For You!': 'اختر الباقة المناسبة لك!',
    '5 Post Credits': 'رصيد 5 منشورات',
    '50 DA': '50 دج',
    'For Those Who Is Just Getting Started':
        'For Those Who Is Just Getting Started',
    '10 0 DA / Post': '10 0 DA / Post',
    'Buy Package': 'شراء الباقة',
    '10 Post Credits': 'رصيد 10 منشورات',
    'For Who Wants To Do More': 'For Who Wants To Do More',
    '90 DA': '90 دج',
    '9 0 DA / Post': '9 0 DA / Post',
    '20 Post Credits': 'رصيد 20 منشورًا',
    'For Those Who Never Stop Creating': 'For Those Who Never Stop Creating',
    '170 DA': '170 دج',
    '8 5 DA / Post': '8 5 DA / Post',
    'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used':
        'Your 3 Free Posts Are Used First Purchased Credits Are Available After Your Free Posts Have Been Used',
    'Edit Profile': 'تعديل الملف الشخصي',
    'Personal Information': 'المعلومات الشخصية',
    'Username': 'اسم المستخدم',
    'Bio': 'نبذة تعريفية',
    'Location': 'الموقع',
    'Save Changes': 'حفظ التغييرات',
    'Update Your Service Details': 'حدّث تفاصيل خدمتك',
    'Existing Media': 'الوسائط الحالية',
    'New Media': 'وسائط جديدة',
    'Followers Following': 'المتابعون والمتابَعون',
    'Remore Follower': 'إزالة متابع',
    'Followings': 'أتابعهم',
    'Are You Sure You Want To Remove': 'هل أنت متأكد أنك تريد إزالة',
    'From Your Followers?': 'من قائمة متابعيك؟',
    'Remove': 'إزالة',
    'Unfollow User': 'إلغاء متابعة المستخدم',
    'Are You Sure You Want To Unfollow': 'هل أنت متأكد أنك تريد إلغاء متابعة',
    'Confirm': 'تأكيد',
    'Choose Display Mode': 'اختر وضع العرض',
    'Light': 'فاتح',
    'Dark': 'داكن',
    'Blocked Accounts': 'الحسابات المحظورة',
    'No Blocked Accounts': 'لا توجد حسابات محظورة',
    'Accounts You Block Will Appear Here': 'ستظهر هنا الحسابات التي تحظرها',
    'Unblock Account?': 'إلغاء حظر الحساب؟',
    'Are You Sure You Want To Unblock': 'هل أنت متأكد أنك تريد إلغاء حظر',
    'Unblock': 'إلغاء الحظر',
    'Privacy Policy': 'سياسة الخصوصية',
    'Your Privacy Matters': 'خصوصيتك مهمة',
    'Learn how Hands handles your information when ':
        'Learn how Hands handles your information when ',
    'You use the app to connect with students and ':
        'You use the app to connect with students and ',
    'Exchange services within your residence.':
        'Exchange services within your residence.',
    '1. Information we collect': '1. Information we collect',
    'Hands may collect information you provide when creating ':
        'Hands may collect information you provide when creating ',
    'Your account, such as your username, email address, ':
        'Your account, such as your username, email address, ',
    'Residence, profile picture, and bio. Content you publish, ':
        'Residence, profile picture, and bio. Content you publish, ',
    'Including posts, comments, and media, may also be stored ':
        'Including posts, comments, and media, may also be stored ',
    'To provide the app services.': 'To provide the app services.',
    '2. Residence-based access': '2. Residence-based access',
    'Hands is designed to connect students within their ':
        'Hands is designed to connect students within their ',
    'Residence. Your residence information is used to help ':
        'Residence. Your residence information is used to help ',
    'Provide residence-based features. This does not mean ':
        'Provide residence-based features. This does not mean ',
    'Every piece of your personal information is visible ':
        'Every piece of your personal information is visible ',
    'To every resident.': 'To every resident.',
    '3. Messages and communication': '3. Messages and communication',
    'Hands allows users to communicate through messages. ':
        'Hands allows users to communicate through messages. ',
    'Messages are intended for the relevant conversation ':
        'Messages are intended for the relevant conversation ',
    'Participants. Do not share passwords, financial details, ':
        'Participants. Do not share passwords, financial details, ',
    'Or other sensitive information in chats. Only describe ':
        'Or other sensitive information in chats. Only describe ',
    'Messages as private or encrypted if the app actually ':
        'Messages as private or encrypted if the app actually ',
    'Provides those protections.': 'Provides those protections.',
    '4. Posts and profile information': '4. Posts and profile information',
    'Information you publish on your profile or in posts may ':
        'Information you publish on your profile or in posts may ',
    'Be visible to other users who are permitted to access it. ':
        'Be visible to other users who are permitted to access it. ',
    'Think carefully before publishing personal details or':
        'Think carefully before publishing personal details or',
    'Uploading photos and videos.': 'Uploading photos and videos.',
    '5. Blocking and reporting': '5. Blocking and reporting',
    'You can use available blocking features to limit ':
        'You can use available blocking features to limit ',
    'Interactions with specific accounts. Reports may be ':
        'Interactions with specific accounts. Reports may be ',
    'Reviewed to help address inappropriate content or ':
        'Reviewed to help address inappropriate content or ',
    'Behavior. Blocking should not be treated as a guarantee ':
        'Behavior. Blocking should not be treated as a guarantee ',
    'That all previous interactions or content are erased.':
        'That all previous interactions or content are erased.',
    '6. Data security': '6. Data security',
    'We use technical and organizational measures intended ':
        'We use technical and organizational measures intended ',
    'To protect account information. No online service can ':
        'To protect account information. No online service can ',
    'Guarantee absolute security. Keep your login credentials ':
        'Guarantee absolute security. Keep your login credentials ',
    'Safe and report suspicious activity.':
        'Safe and report suspicious activity.',
    '7. Storage and service providers': '7. Storage and service providers',
    'Information may be processed by the service providers ':
        'Information may be processed by the service providers ',
    'Needed to operate Hands, such as database, media storage, ':
        'Needed to operate Hands, such as database, media storage, ',
    'Authentication, and payment providers, where applicable. ':
        'Authentication, and payment providers, where applicable. ',
    'The final policy should identify the providers actually ':
        'The final policy should identify the providers actually ',
    'Used and explain their relevant roles.':
        'Used and explain their relevant roles.',
    '8. Your choices and your data': '8. Your choices and your data',
    'You can manage information through the settings and ':
        'You can manage information through the settings and ',
    'Features available in Hands. You may request access to, ':
        'Features available in Hands. You may request access to, ',
    'Correction of, or deletion of your personal information, ':
        'Correction of, or deletion of your personal information, ',
    'Subject to applicable law and legitimate retention ':
        'Subject to applicable law and legitimate retention ',
    'Requirements. Add your actual account-deletion process ':
        'Requirements. Add your actual account-deletion process ',
    'And contact details before publishing this policy.':
        'And contact details before publishing this policy.',
    '9. Age requirements': '9. Age requirements',
    'Hands is intended for its eligible student audience. ':
        'Hands is intended for its eligible student audience. ',
    'The app should apply and communicate its actual minimum ':
        'The app should apply and communicate its actual minimum ',
    'Age requirements and comply with the laws applicable ':
        'Age requirements and comply with the laws applicable ',
    'To its users.': 'To its users.',
    '10. Changes to this policy': '10. Changes to this policy',
    'This policy may be updated when Hands changes its ':
        'This policy may be updated when Hands changes its ',
    'Features or legal requirements change. When appropriate, ':
        'Features or legal requirements change. When appropriate, ',
    'Users will be informed of significant changes.':
        'Users will be informed of significant changes.',
    '11. Contact us': '11. Contact us',
    'For questions about this policy or your personal ':
        'For questions about this policy or your personal ',
    'Information, contact the Hands team at the official ':
        'Information, contact the Hands team at the official ',
    'Privacy email address published by the app developer.':
        'Privacy email address published by the app developer.',
    'Draft for review — add the effective date and ':
        'Draft for review — add the effective date and ',
    'Verified contact details before publication.':
        'Verified contact details before publication.',
    'Terms Of Service': 'Terms of Service',
    'Welcome to Hands!': 'مرحبًا بك في Hands!',
    'Hands connects students living in the ':
        'Hands connects students living in the ',
    'Same residence to share services, ': 'Same residence to share services, ',
    'Offer skills, and help each other.': 'Offer skills, and help each other.',
    '1. Acceptance of Terms': '1. Acceptance of Terms',
    'By creating an account or using Hands, you agree ':
        'By creating an account or using Hands, you agree ',
    'To follow these Terms of Service and applicable ':
        'To follow these Terms of Service and applicable ',
    'Laws. If you do not agree, please stop using ':
        'Laws. If you do not agree, please stop using ',
    'The platform.': 'The platform.',
    '2. Eligibility and Accounts': '2. Eligibility and Accounts',
    'Hands is designed for students within participating ':
        'Hands is designed for students within participating ',
    'Student residences. You must provide accurate ':
        'Student residences. You must provide accurate ',
    'Information, keep your account credentials secure, ':
        'Information, keep your account credentials secure, ',
    'And not impersonate another person or create ':
        'And not impersonate another person or create ',
    'Fraudulent accounts.': 'Fraudulent accounts.',
    '3. Posts and Services': '3. Posts and Services',
    'You are responsible for the content you publish ':
        'You are responsible for the content you publish ',
    'And the services you offer. Posts must be accurate, ':
        'And the services you offer. Posts must be accurate, ',
    'Respectful, and lawful. Do not publish misleading ':
        'Respectful, and lawful. Do not publish misleading ',
    'Offers, prohibited content, spam, or services ':
        'Offers, prohibited content, spam, or services ',
    'That could endanger other students.':
        'That could endanger other students.',
    '4. Communication and Conduct': '4. Communication and Conduct',
    'Treat other users respectfully. Harassment, threats, ':
        'Treat other users respectfully. Harassment, threats, ',
    'Fraud, discrimination, impersonation, and misuse ':
        'Fraud, discrimination, impersonation, and misuse ',
    'Of private information are not permitted. You may ':
        'Of private information are not permitted. You may ',
    'Block or report users who violate these rules.':
        'Block or report users who violate these rules.',
    '5. Transactions and Payments': '5. Transactions and Payments',
    'Users are responsible for agreeing on service ':
        'Users are responsible for agreeing on service ',
    'Details, prices, delivery, and payment arrangements. ':
        'Details, prices, delivery, and payment arrangements. ',
    'Hands does not guarantee the quality, completion, ':
        'Hands does not guarantee the quality, completion, ',
    'Or outcome of services offered by other users. ':
        'Or outcome of services offered by other users. ',
    'Any paid post-credit purchases are subject to ':
        'Any paid post-credit purchases are subject to ',
    'The prices and conditions displayed at purchase.':
        'The prices and conditions displayed at purchase.',
    '6. Free Posts and Paid Credits': '6. Free Posts and Paid Credits',
    'Hands may provide a limited number of free posts ':
        'Hands may provide a limited number of free posts ',
    'And offer additional posting credits for purchase. ':
        'And offer additional posting credits for purchase. ',
    'Available allowances, prices, and applicable ':
        'Available allowances, prices, and applicable ',
    'Conditions will be displayed in the app. Do not ':
        'Conditions will be displayed in the app. Do not ',
    'Attempt to bypass posting limits or manipulate ':
        'Attempt to bypass posting limits or manipulate ',
    'Payment confirmations.': 'Payment confirmations.',
    '7. Privacy and Safety': '7. Privacy and Safety',
    'Use other students’ personal information only ':
        'Use other students’ personal information only ',
    'For legitimate purposes related to the platform. ':
        'For legitimate purposes related to the platform. ',
    'Do not share private messages, contact details, ':
        'Do not share private messages, contact details, ',
    'Or other personal information without appropriate':
        'Or other personal information without appropriate',
    'Permission. Review our Privacy Policy to understand ':
        'Permission. Review our Privacy Policy to understand ',
    'How personal information is handled.':
        'How personal information is handled.',
    '8. Reporting and Account Restrictions':
        '8. Reporting and Account Restrictions',
    'Hands may review reported content and take ':
        'Hands may review reported content and take ',
    'Appropriate action against accounts that violate ':
        'Appropriate action against accounts that violate ',
    'These terms, including removing posts, restricting ':
        'These terms, including removing posts, restricting ',
    'Features, or suspending accounts, where appropriate.':
        'Features, or suspending accounts, where appropriate.',
    '9. Service Availability': '9. Service Availability',
    'We aim to keep Hands available and functioning ':
        'We aim to keep Hands available and functioning ',
    'Properly, but uninterrupted access is not ':
        'Properly, but uninterrupted access is not ',
    'Guaranteed. Features may be updated, changed, ':
        'Guaranteed. Features may be updated, changed, ',
    'Or temporarily unavailable.': 'Or temporarily unavailable.',
    '10. Changes to These Terms': '10. Changes to These Terms',
    'These terms may be updated as Hands evolves. ':
        'These terms may be updated as Hands evolves. ',
    'Material changes should be communicated through ':
        'Material changes should be communicated through ',
    'Appropriate channels. Continued use after updated ':
        'Appropriate channels. Continued use after updated ',
    'Terms take effect may be subject to those terms, ':
        'Terms take effect may be subject to those terms, ',
    'As permitted by applicable law.': 'As permitted by applicable law.',
    '11. Contact Us': '11. Contact Us',
    'If you have questions about these terms, contact ':
        'If you have questions about these terms, contact ',
    'The Hands team through the official support ':
        'The Hands team through the official support ',
    'Channel provided in the app.': 'Channel provided in the app.',
    'Help Support': 'المساعدة والدعم',
    'How can we help you?': 'كيف يمكننا مساعدتك؟',
    'Find answers to common questions or ':
        'اعثر على إجابات للأسئلة الشائعة أو ',
    'Get help with your Hands account.': 'Get help with your Hands account.',
    'Frequently asked questions': 'الأسئلة الشائعة',
    'What is Hands?': 'ما هو Hands؟',
    'Hands is a social marketplace designed for students living ':
        'Hands is a social marketplace designed for students living ',
    'In the same residence. It combines social media features ':
        'In the same residence. It combines social media features ',
    'With a platform where students can offer services, discover ':
        'With a platform where students can offer services, discover ',
    'What others provide, connect through messages, and support ':
        'What others provide, connect through messages, and support ',
    'Their student community.': 'Their student community.',
    'Why can I only see certain posts?': 'لماذا لا أرى سوى منشورات معينة؟',
    'Posts are intended for students in your residence. ':
        'Posts are intended for students in your residence. ',
    'Make sure your account is associated with the ':
        'Make sure your account is associated with the ',
    'Correct residence.': 'Correct residence.',
    'How can I publish a post?': 'كيف يمكنني نشر منشور؟',
    'Open the create-post screen, add your service ':
        'Open the create-post screen, add your service ',
    'Details and media, then follow the instructions ':
        'Details and media, then follow the instructions ',
    'To publish. Posting allowances and any applicable ':
        'To publish. Posting allowances and any applicable ',
    'Credit requirements are shown in the app. ':
        'Credit requirements are shown in the app. ',
    'Why can’t I publish another post?': 'لماذا لا أستطيع نشر منشور آخر؟',
    'You may have used your free posting allowance ':
        'You may have used your free posting allowance ',
    'And may need additional post credits. Check the ':
        'And may need additional post credits. Check the ',
    'Credits section in your profile.': 'Credits section in your profile.',
    'How do I block or report someone?': 'كيف أحظر شخصًا أو أبلّغ عنه؟',
    'Open the relevant profile or post and use the ':
        'Open the relevant profile or post and use the ',
    'Available block or report option. If someone ':
        'Available block or report option. If someone ',
    'Makes you feel unsafe, avoid sharing personal ':
        'Makes you feel unsafe, avoid sharing personal ',
    'Information and contact support.': 'Information and contact support.',
    'How can I edit my profile?': 'كيف أعدّل ملفي الشخصي؟',
    'Open your profile and use the available profile ':
        'Open your profile and use the available profile ',
    'Editing option to update your username, bio, ':
        'Editing option to update your username, bio, ',
    'Or profile picture.': 'Or profile picture.',
    'Still need help?': 'ما زلت بحاجة إلى المساعدة؟',
    'Choose an option below to get assistance.':
        'اختر أحد الخيارات أدناه للحصول على المساعدة.',
    'Log Out?': 'Log out?',
    'Are you sure you want to log out of your Hands account?':
        'هل أنت متأكد أنك تريد تسجيل الخروج من حساب Hands؟',
    'Cancle': 'Cancle',
    'Log out': 'تسجيل الخروج',
    'Delete account?': 'حذف الحساب؟',
    'Are you sure you want to permanently ': 'هل أنت متأكد أنك تريد حذف ',
    'Delete your Hands account? This action ':
        'Delete your Hands account? This action ',
    'Cannot be undone.': 'Cannot be undone.',
    'No posts yet. Be the first who post!':
        'لا توجد منشورات بعد. كن أول من ينشر!',
    'No posts yet': 'لا توجد منشورات بعد',
    'No posts found for ': 'لم يتم العثور على منشورات لـ ',
    'Send message': 'إرسال رسالة',
    'Share profile': 'مشاركة الملف الشخصي',
    'Block account': 'حظر الحساب',
    'Report account': 'الإبلاغ عن الحساب',
  },
};

String text(BuildContext context, String key) {
  final locale = context.watch<LanguageManager>().locale.languageCode;
  return languages[locale]?[key] ?? languages['en']?[key] ?? key;
}
