import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hands/services/lang_manager.dart';

const Map<String, Map<String, String>> languages = {
  'en': {
    'Home': 'Home',
    'Search': 'Search',
    'Explore': 'Explore',
    'Messages': 'Messages',
    'Profile': 'Profile',
    'Settings': 'Settings',
    'Language': 'Language',
    'Choose language': 'Choose language',
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
    'Exchange': 'Exchange',
    'Projects': 'Projects',
    'Programming': 'Programming',
    'Trips': 'Trips',
    'Lost & Found': 'Lost & Found',
    'Rentals & Borrowing': 'Rentals & Borrowing',
    'Questions & Answers': 'Questions & Answers',
    'Other': 'Other',
    'Cancel': 'Cancel',
    'Save': 'Save',
    'Delete': 'Delete',
    'Report': 'Report',
    'No Posts': 'No posts yet',
    'Search Hint': 'Discover services in your residence',
    'Edit post': 'Edit post',
    'Delete post?': 'Delete post?',
    'Delete post': 'Delete post',
    'Report post': 'Report post',
    'Block user': 'Block user',
    'Block user?': 'Block user?',
    'Reply to ': 'Reply to ',
    'Comments': 'Comments',
    'Text ': 'Text ',
    'Search ...': 'Search ...',
    'No comments yet. Be the first !': 'No comments yet. Be the first !',
    'Write a comment...': 'Write a comment...',
    'Write a reply...': 'Write a reply...',
    'Delete reply?': 'Delete reply ?',
    'Edit comment': 'Edit comment',
    'Edit': 'Edit',
    'Reply': 'Reply',
    'Edit reply': 'Edit reply',
    'No posts about': 'No posts about',
    'yet.': 'yet.',
    'Posts': 'Posts',
    'Followed': 'Followed',
    'Follow': 'Follow',
    'Users': 'Users',
    'Groups': 'Groups',
    'Create a post': 'Create a post',
    'Profile options': 'Profile options',
    'Share your service with your residence !':
        'Share your service with your residence!',
    'Category': 'Category',
    'Caption': 'Caption',
    'Add photos or videos': 'Add photos or videos',
    'Publish post': 'Publish post',
    'Describe your service...': 'Describe your service...',
    'Caption is required': 'Caption is required',
    'Search people or groups': 'Search people or groups',
    'Direct messages': 'Direct messages',
    'Create a group': 'Create a group',
    'Group name': 'Group name',
    'Search users': 'Search users',
    'Create group': 'Create group',
    'student(s) selected': 'student(s) selected',
    'Following': 'Following',
    'Followers': 'Followers',
    'Are you sure you want to leave this group?':
        'Are you sure you want to leave this group?',
    'Leave': 'Leave',
    'Replies': 'Replies',
    'Delete comment?': 'Delete comment?',
    'Post Credits': 'Post Credits',
    'Your balance': 'Your balance',
    'Keep track of the posts you can publish.':
        'Keep track of the posts you can publish.',
    'Free posts left': 'Free posts left',
    'Paid post credits': 'Paid post credits',
    'Get more post credits': 'Get more post credits',
    'Choose the package that works for you !':
        'Choose the package that works for you !',
    'Post credits': 'Post credits',
    '50 DA': '50 DA',
    'For who is just getting started.': 'For who is just getting started.',
    'DA / post': 'DA / post',
    'Buy package': 'Buy package',
    'For who wants to do more.': 'For who wants to do more.',
    'For who never stop creating.': 'For who never stop creating.',
    ' has been blocked.': ' has been blocked.',
    'Your 3 free posts are used first. Purchased credits are available after your free posts have been used.':
        'Your 3 free posts are used first. Purchased credits are available after your free posts have been used.',
    'Edit profile': 'Edit profile',
    'Personal information': 'Personal information',
    'Username': 'Username',
    'Bio': 'Bio',
    'Location': 'Location',
    'Save changes': 'Save changes',
    'Update your service details': 'Update your service details',
    'Existing media': 'Existing media',
    'New media': 'New media',
    'Followers & Following': 'Followers & Following',
    'Remore follower?': 'Remove follower?',
    'Followings': 'Following',
    'Leave group': 'Leave group',
    'Leave group?': 'Leave group?',
    'Are you sure you want to remove': 'Are you sure you want to remove',
    'from your followers?': 'from your followers?',
    'Are you sure you want to delete this post? This action cannot be undone.':
        'Are you sure you want to delete this post? This action cannot be undone.',
    'Remove': 'Remove',
    'remove': 'remove',
    'Unfollow user?': 'Unfollow user?',
    'Report user': 'Report user',
    'unfollow': ' unfollow',
    'Are you sure you want to': 'Are you sure you want to',
    'Why are you reporting this user?': 'Why are you reporting this user?',
    'Confirm': 'Confirm',
    'Choose display mode': 'Choose display mode',
    'Mode': 'Mode',
    'Light': 'Light',
    'Dark': 'Dark',
    'Blocked accounts': 'Blocked accounts',
    'No blocked accounts': 'No blocked accounts',
    'Are you sure you want to block': 'Are you sure you want to block',
    'Their posts will no longer appear in your feed.':
        'Their posts will no longer appear in your feed.',

    'Unblock account?': 'Unblock account?',
    'Are you sure you want to unblock': 'Are you sure you want to unblock',
    'Unblock': 'Unblock',
    'Block': 'Block',
    'Privacy Policy': 'Privacy Policy',
    'Your privacy matters': 'Your privacy matters',
    'Learn how Hands handles your information when ':
        'Learn how Hands handles your information when ',
    'you use the app to connect with students and ':
        'you use the app to connect with students and ',
    'Exchange services within your residence.':
        'Exchange services within your residence.',
    '1. Information we collect': '1. Information we collect',
    'Hands may collect information you provide when creating ':
        'Hands may collect information you provide when creating ',
    'your account, such as your username, email address, ':
        'your account, such as your username, email address, ',
    'residence, profile picture, and bio. Content you publish, ':
        'residence, profile picture, and bio. Content you publish, ',
    'including posts, comments, and media, may also be stored ':
        'including posts, comments, and media, may also be stored ',
    'to provide the app services.': 'to provide the app services.',
    '2. Residence-based access': '2. Residence-based access',
    'Hands is designed to connect students within their ':
        'Hands is designed to connect students within their ',
    'residence. Your residence information is used to help ':
        'residence. Your residence information is used to help ',
    'provide residence-based features. This does not mean ':
        'provide residence-based features. This does not mean ',
    'every piece of your personal information is visible ':
        'every piece of your personal information is visible ',
    'to every resident.': 'to every resident.',
    '3. Messages and communication': '3. Messages and communication',
    'Hands allows users from the same residenceto communicate through messages. ':
        'Hands allows users from the same residence to communicate through messages. ',
    'Messages are intended for the relevant conversation ':
        'Messages are intended for the relevant conversation ',
    'participants. Do not share passwords, financial details, ':
        'participants. Do not share passwords, financial details, ',
    'or other sensitive information in chats. Only describe ':
        'or other sensitive information in chats. Only describe ',
    'messages as private or encrypted.': 'messages as private or encrypted.',

    '4. Posts and profile information': '4. Posts and profile information',
    'Information you publish on your profile or in posts may ':
        'Information you publish on your profile or in posts may ',
    'be visible to other users who are permitted to access it. ':
        'be visible to other users who are permitted to access it. ',
    'Think carefully before publishing personal details or ':
        'Think carefully before publishing personal details or ',
    'uploading photos and videos.': 'uploading photos and videos.',
    '5. Blocking and reporting': '5. Blocking and reporting',
    'You can use available blocking features to limit ':
        'You can use available blocking features to limit ',
    'interactions with specific accounts. Reports may be ':
        'interactions with specific accounts. Reports may be ',
    'reviewed to help address inappropriate content or ':
        'reviewed to help address inappropriate content or ',
    'behavior. Blocking should not be treated as a guarantee ':
        'behavior. Blocking should not be treated as a guarantee ',
    'that all previous interactions or content are erased.':
        'that all previous interactions or content are erased.',
    '6. Data security': '6. Data security',
    'We use technical and organizational measures intended ':
        'We use technical and organizational measures intended ',
    'to protect account information. No online service can ':
        'to protect account information. No online service can ',
    'guarantee absolute security. Keep your login credentials ':
        'guarantee absolute security. Keep your login credentials ',
    'safe and report suspicious activity.':
        'safe and report suspicious activity.',
    '7. Storage and service providers': '7. Storage and service providers',
    'Information may be processed by the service providers ':
        'Information may be processed by the service providers ',
    'needed to operate Hands, such as database, media storage, ':
        'needed to operate Hands, such as database, media storage, ',
    'authentication, and payment providers, where applicable. ':
        'authentication, and payment providers, where applicable. ',
    'The final policy should identify the providers actually ':
        'The final policy should identify the providers actually ',
    'used and explain their relevant roles.':
        'used and explain their relevant roles.',
    '8. Your choices and your data': '8. Your choices and your data',
    'You can manage information through the settings and ':
        'You can manage information through the settings and ',
    'features available in Hands. You may request access to, ':
        'features available in Hands. You may request access to, ',
    'correction of, or deletion of your personal information, ':
        'correction of, or deletion of your personal information, ',
    'subject to applicable law and legitimate retention ':
        'subject to applicable law and legitimate retention ',
    'requirements. Add your actual account-deletion process ':
        'requirements. Add your actual account-deletion process ',
    'and contact details before publishing this policy.':
        'and contact details before publishing this policy.',
    '9. Age requirements': '9. Age requirements',
    'Hands is intended for its eligible student audience. ':
        'Hands is intended for its eligible student audience. ',
    'The app should apply and communicate its actual minimum ':
        'The app should apply and communicate its actual minimum ',
    'age requirements and comply with the laws applicable ':
        'age requirements and comply with the laws applicable ',
    'To its users.': 'To its users.',
    '10. Changes to this policy': '10. Changes to this policy',
    'This policy may be updated when Hands changes its ':
        'This policy may be updated when Hands changes its ',
    'features or legal requirements change. When appropriate, ':
        'features or legal requirements change. When appropriate, ',
    'users will be informed of significant changes.':
        'users will be informed of significant changes.',
    '11. Contact us': '11. Contact us',
    'For questions about this policy or your personal ':
        'For questions about this policy or your personal ',
    'information, contact the Hands team at the official ':
        'information, contact the Hands team at the official ',
    'privacy email address @@@@@@@@@2@@@@@@@':
        'privacy email address @@@@@@@@@2@@@@@@@',

    'Terms of Service': 'Terms of Service',
    'Welcome to Hands!': 'Welcome to Hands!',
    'Read the rules and conditions for using Hands ':
        'Read the rules and conditions for using Hands ',
    'to connect with students, offer services, ':
        'to connect with students, offer services, ',
    'and exchange help within your residence.':
        'and exchange help within your residence.',
    'Hands connects students living in the ':
        'Hands connects students living in the ',
    'same residence to share services, ': 'same residence to share services, ',
    'offer skills, and help each other.': 'offer skills, and help each other.',
    '1. Acceptance of Terms': '1. Acceptance of Terms',
    'by creating an account or using Hands, you agree ':
        'by creating an account or using Hands, you agree ',
    'to follow these Terms of Service and applicable ':
        'to follow these Terms of Service and applicable ',
    'laws. If you do not agree, please stop using ':
        'laws. If you do not agree, please stop using ',
    'The platform.': 'The platform.',
    '2. Eligibility and Accounts': '2. Eligibility and Accounts',
    'Hands is designed for students within participating ':
        'Hands is designed for students within participating ',
    'student residences. You must provide accurate ':
        'student residences. You must provide accurate ',
    'information, keep your account credentials secure, ':
        'information, keep your account credentials secure, ',
    'and not impersonate another person or create ':
        'and not impersonate another person or create ',
    'Fraudulent accounts.': 'Fraudulent accounts.',
    '3. Posts and Services': '3. Posts and Services',
    'You are responsible for the content you publish ':
        'You are responsible for the content you publish ',
    'and the services you offer. Posts must be accurate, ':
        'and the services you offer. Posts must be accurate, ',
    'respectful, and lawful. Do not publish misleading ':
        'respectful, and lawful. Do not publish misleading ',
    'offers, prohibited content, spam, or services ':
        'offers, prohibited content, spam, or services ',
    'that could endanger other students.':
        'that could endanger other students.',
    '4. Communication and Conduct': '4. Communication and Conduct',
    'Treat other users respectfully. Harassment, threats, ':
        'Treat other users respectfully. Harassment, threats, ',
    'fraud, discrimination, impersonation, and misuse ':
        'fraud, discrimination, impersonation, and misuse ',
    'of private information are not permitted. You may ':
        'of private information are not permitted. You may ',
    'block or report users who violate these rules.':
        'block or report users who violate these rules.',
    '5. Transactions and Payments': '5. Transactions and Payments',
    'Users are responsible for agreeing on service ':
        'Users are responsible for agreeing on service ',
    'details, prices, delivery, and payment arrangements. ':
        'details, prices, delivery, and payment arrangements. ',
    'Hands does not guarantee the quality, completion, ':
        'Hands does not guarantee the quality, completion, ',
    'or outcome of services offered by other users. ':
        'or outcome of services offered by other users. ',
    'Any paid post-credit purchases are subject to ':
        'Any paid post-credit purchases are subject to ',
    'the prices and conditions displayed at purchase.':
        'the prices and conditions displayed at purchase.',
    '6. Free Posts and Paid Credits': '6. Free Posts and Paid Credits',
    'Hands may provide a limited number of free posts (3) ':
        'Hands may provide a limited number of free posts (3) ',
    'and offer additional posting credits for purchase. ':
        'and offer additional posting credits for purchase. ',
    'Available allowances, prices, and applicable ':
        'Available allowances, prices, and applicable ',
    'conditions will be displayed in the app. Do not ':
        'conditions will be displayed in the app. Do not ',
    'attempt to bypass posting limits or manipulate ':
        'attempt to bypass posting limits or manipulate ',
    'payment confirmations.': 'payment confirmations.',
    '7. Privacy and Safety': '7. Privacy and Safety',
    'Use other students’ personal information only ':
        'Use other students’ personal information only ',
    'for legitimate purposes related to the platform. ':
        'for legitimate purposes related to the platform. ',
    'Do not share private messages, contact details, ':
        'Do not share private messages, contact details, ',
    'or other personal information without appropriate ':
        'or other personal information without appropriate ',
    'permission. Review our Privacy Policy to understand ':
        'permission. Review our Privacy Policy to understand ',
    'how personal information is handled.':
        'how personal information is handled.',
    '8. Reporting and Account Restrictions':
        '8. Reporting and Account Restrictions',
    'Hands may review reported content and take ':
        'Hands may review reported content and take ',
    'appropriate action against accounts that violate ':
        'appropriate action against accounts that violate ',
    'these terms, including removing posts, restricting ':
        'these terms, including removing posts, restricting ',
    'features, or suspending accounts, where appropriate.':
        'features, or suspending accounts, where appropriate.',
    '9. Service Availability': '9. Service Availability',
    'We aim to keep Hands available and functioning ':
        'We aim to keep Hands available and functioning ',
    'properly, but uninterrupted access is not ':
        'properly, but uninterrupted access is not ',
    'guaranteed. Features may be updated, changed, ':
        'guaranteed. Features may be updated, changed, ',
    'or temporarily unavailable.': 'or temporarily unavailable.',
    '10. Changes to These Terms': '10. Changes to These Terms',
    'These terms may be updated as Hands evolves. ':
        'These terms may be updated as Hands evolves. ',
    'Material changes should be communicated through ':
        'Material changes should be communicated through ',
    'appropriate channels. Continued use after updated ':
        'appropriate channels. Continued use after updated ',
    'terms take effect may be subject to those terms, ':
        'terms take effect may be subject to those terms, ',
    'as permitted by applicable law.': 'as permitted by applicable law.',
    '11. Contact Us': '11. Contact Us',
    'If you have questions about these terms, contact ':
        'If you have questions about these terms, contact ',
    'the Hands team through the official support ':
        'the Hands team through the official support ',
    'email provided in the app.': 'email provided in the app.',
    'Hands - To survive in your residence.':
        'Hands - To survive in your residence.',
    'Help & Support': 'Help & Support',
    'How can we help you?': 'How can we help you?',
    'Find answers to common questions or get help':
        'Find answers to common questions or get help',
    'with your Hands account and services within your residence.':
        'with your Hands account and services within your residence.',
    'Frequently asked questions :': 'Frequently asked questions :',
    'What is Hands?': 'What is Hands?',
    'Hands is a social marketplace designed for students living ':
        'Hands is a social marketplace designed for students living ',
    'in the same residence. It combines social media features ':
        'in the same residence. It combines social media features ',
    'with a platform where students can offer services, discover ':
        'with a platform where students can offer services, discover ',
    'what others provide, connect through messages, and support ':
        'what others provide, connect through messages, and support ',
    'their student community.': 'their student community.',
    'Why can I only see certain posts?': 'Why can I only see certain posts?',
    'Posts are intended for students in your residence. ':
        'Posts are intended for students in your residence. ',
    'Make sure your account is associated with the ':
        'Make sure your account is associated with the ',
    'correct residence.': 'correct residence.',
    'How can I publish a post?': 'How can I publish a post?',
    'Open the create-post screen, add your service ':
        'Open the create-post screen, add your service ',
    'details and media, then follow the instructions ':
        'details and media, then follow the instructions ',
    'to publish. Posting allowances and any applicable ':
        'to publish. Posting allowances and any applicable ',
    'credit requirements are shown in the app.':
        'credit requirements are shown in the app.',
    'Why can’t I publish another post?': 'Why can’t I publish another post?',
    'You may have used your free posting allowance ':
        'You may have used your free posting allowance ',
    'and may need additional post credits. Check the ':
        'and may need additional post credits. Check the ',
    'credits section in your profile.': 'credits section in your profile.',
    'How do I block or report someone?': 'How do I block or report someone?',
    'Open the relevant profile or post and use the ':
        'Open the relevant profile or post and use the ',
    'available block or report option. If someone ':
        'available block or report option. If someone ',
    'makes you feel unsafe, avoid sharing personal ':
        'makes you feel unsafe, avoid sharing personal ',
    'information and contact support.': 'information and contact support.',
    'How can I edit my profile?': 'How can I edit my profile?',
    'Open your profile and use the available profile ':
        'Open your profile and use the available profile ',
    'editing option to update your username, bio, ':
        'editing option to update your username, bio, ',
    'or profile picture.': 'or profile picture.',
    'Still need help?': 'Still need help?',
    'Choose an option below to get assistance.':
        'Choose an option below to get assistance.',
    'Log out?': 'Log out?',
    'Are you sure you want to log out of your Hands account?':
        'Are you sure you want to log out of your Hands account?',
    'Cancle': 'Cancle',
    'Log out': 'Log out',
    'Delete account?': 'Delete account?',
    'Delete account': 'Delete account',
    'Are you sure you want to permanently ':
        'Are you sure you want to permanently ',
    'delete your Hands account? This action ':
        'delete your Hands account? This action ',
    'cannot be undone.': 'cannot be undone.',
    'This action cannot be undone.': 'This action cannot be undone.',
    'No posts yet. Be the first who post!':
        'No posts yet. Be the first who post!',
    'No posts yet': 'No posts yet',
    'No posts found for ': 'No posts found for ',
    'Send message': 'Send message',
    'Share profile': 'Share profile',
    'Block account': 'Block account',
    'Report account': 'Report account',
    'Why are you reporting this post?': 'Why are you reporting this post?',
    'Inappropriate content': 'Inappropriate content',
    'Scam or fraud': 'Scam or fraud',
    'Spam or fake account': 'Spam or fake account',
    'Harassment or bullying': 'Harassment or bullying',
    'Pretending to be someone else': 'Pretending to be someone else',
    'Submit report': 'Submit report',
    'Additional details (optional)': 'Additional details (optional)',
    'Start the conversation!': 'Start the conversation!',
    'Send the first message to your group.':
        'Send the first message to your group.',
    'Message your group...': 'Message your group...',
    'Tell students a little about yourself !':
        'Tell students a little about yourself!',
    'Please select your Wilaya and residence.':
        'Please select your Wilaya and residence.',
    'Bio cannot exceed 300 characters.': 'Bio cannot exceed 300 characters.',
    'Get help with an account or a problem':
        'Get help with an account or a problem',
  },
  'fr': {
    'Home': 'Accueil',
    'Search': 'Rechercher',
    'Explore': 'Recherche',
    'Messages': 'Messages',
    'Profile': 'Profil',
    'Settings': 'Paramètres',
    'Language': 'Langue',
    'Choose language': 'Choisir une langue',
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
    'Exchange': 'Exchange',
    'Projects': 'Projets',
    'Programming': 'Programmation',
    'Trips': 'Sorties',
    'Lost & Found': 'Objets perdus et trouvés',
    'Rentals & Borrowing': 'Location et emprunt',
    'Questions & Answers': 'Questions et réponses',
    'Other': 'Autre',
    'Cancel': 'Annuler',
    'Delete comment?': 'Supprimer le commentaire ?',
    'Save': 'Enregistrer',
    'Delete': 'Supprimer',
    'Reply to ': 'Répondre à ',
    'Report': 'Signaler',
    'No Posts': 'Aucune publication pour le moment',
    'Search hint': 'Découvrez les services de votre résidence',
    'Edit post': 'Modifier la publication',
    'Delete post?': 'Supprimer la publication',
    'Delete post': 'Supprimer la publication',
    'Report post': 'Signaler la publication',
    'Block user': 'Bloquer l’utilisateur',
    'Block user?': 'Bloquer l’utilisateur?',
    'Block': 'Bloquer',
    'Comments': 'Commentaires',
    'No comments yet. Be the first !': 'Aucun commentaire. Soyez le premier !',
    'Write a comment...': 'Écrire un commentaire',
    'Write a reply...': 'Écrire une response',
    'Edit comment': 'Modifier un commentaire',
    'Delete reply?': 'Supprimer une response ?',
    'Profile options': 'Options du profil',
    'Edit': 'Modifier',
    'Reply': 'Répondre',
    'Edit reply': 'Modifier la réponse',
    'No posts about': 'Aucune pubs sur',
    'yet.': 'encore.',
    ' has been blocked.': ' a été bloqué.',
    'Posts': 'Publications',
    'Users': 'Utilisateurs',
    'Groups': 'Groupes',
    'Followed': 'Abonné',
    'Follow': 'Suivre',
    'Create a post': 'Créer une publication',
    'Share your service with your residence !':
        'Partagez votre service avec votre résidence !',
    'Category': 'Catégorie',
    'Caption': 'Description',
    'Add photos or videos': 'Ajouter photos ou vidéos',
    'Publish post': 'Publier',
    'Text ': 'DM ',
    'student(s) selected': 'étudiant(s) sélectionné(s)',
    'Search ...': 'Rechercher...',
    'Create group': 'Creet un group',
    'Caption is required': 'La description est obligatoire',
    'Describe your service...': 'Décrivez votre service...',
    'Search people or groups': 'Rechercher des personnes ou des groupes',
    'Direct messages': 'Messages privés',
    'Create a group': 'Créer un groupe',
    'Leave group': 'Quitter le groupe',
    'Leave group?': 'Quitter le groupe?',
    'Group name': 'Nom du groupe',
    'Search users': 'Search users',
    'Following': 'Abonnements',
    'Followers': 'Abonnés',
    'You don’t have any followers yet.': 'Vous n’avez pas encore d’abonnés.',
    'You aren’t following anyone yet.': 'Vous ne suivez encore personne.',
    'Replies': 'Réponses',
    'Post Credits': 'Crédits de publication',
    'Your balance': 'Votre solde',
    'Keep track of the posts you can publish.':
        'Suivez le nombre de publications que vous pouvez publier',
    'Free posts left': 'Publications\ngratuites restantes',
    'Paid post credits': 'Crédits de publication payants',
    'Get more post credits': 'Obtenir plus de crédits',
    'Choose the package that works for you !':
        'Choisissez le forfait qui vous convient !',
    '5 Post credits': '5 Crédits de publication',
    'Why are you reporting this user?':
        'Pourquoi signalez-vous cet utilisateur ?',

    'For who is just getting started.': 'Pour ceux qui débutent tout juste.',
    'DA / post': 'DA / pub',
    'Buy package': 'Acheter le forfait',
    '10 Post credits': '10 crédits de publication',
    'For who wants to do more.': 'Pour ceux qui souhaitent en faire davantage.',
    '90 DA': '90 DA',
    'Are you sure you want to leave this group?':
        'Êtes-vous sûr de vouloir quitter ce groupe ?',
    'Leave': 'Quitter',
    '20 Post Credits': '20 crédits de publication',
    'For who never stop creating.': 'Pour ceux qui ne cessent jamais de créer.',
    'Are you sure you want to block': 'Êtes-vous sûr de vouloir bloquer',
    'Their posts will no longer appear in your feed.':
        'Leurs publications n’apparaîtront plus dans votre fil d’actualité.',

    'Mode': 'Mode',
    'Your 3 free posts are used first. Purchased credits are available after your free posts have been used.':
        'Vos 3 publications gratuites sont utilisées en priorité ; les crédits achetés deviennent disponibles une fois vos publications gratuites épuisées.',
    'Edit profile': 'Modifier le profil',
    'Personal information': 'Informations personnelles',
    'Username': 'Nom d’utilisateur',
    'Bio': 'Biographie',
    'Location': 'Localisation',
    'Save changes': 'Modifier',
    'Update your service details': 'Mettez à jour les détails de votre service',
    'Existing media': 'Médias existants',
    'New media': 'Nouveaux médias',
    'Followers & Following': 'Abonnés et abonnements',
    'Remore follower': 'Retirer un abonné',
    'Followings': 'Abonnements',
    'Are you sure you want to remove': 'Voulez-vous vraiment retirer',
    'from your followers?': 'de vos abonnés ?',
    'Remove': 'Retirer',
    'remove': 'retirer',
    'Report user': 'Signaler cet utilisateur',
    'Unfollow user?': 'Se désabonner?',
    'Remove follower?': 'Supprimer cet abonné ?',
    'unfollow': ' désabonner',
    'Are you sure you want to': 'Voulez-vous vraiment vous',
    'Are you sure you want to delete this post? This action cannot be undone.':
        'Voulez-vous vraiment supprimer cette publication ? Cette action est irréversible.',
    'Confirm': 'Confirmer',
    'Choose display mode': 'Choisir le mode d’affichage',
    'Light': 'Clair',
    'Dark': 'Sombre',
    'Blocked accounts': 'Comptes bloqués',
    'No blocked accounts': 'Aucun compte bloqué',

    'Unblock account?': 'Débloquer ce compte ?',
    'Are you sure you want to unblock': 'Voulez-vous vraiment débloquer',
    'Unblock': 'Débloquer',
    'Privacy Policy': 'Politique de confidentialité',
    'Your privacy matters': 'Votre vie privée compte',
    'Learn how Hands handles your information when ':
        'Découvrez comment Hands traite vos informations lorsque ',
    'you use the app to connect with students and ':
        'vous utilisez l’application pour entrer en contact avec d’autres étudiants et ',
    'Exchange services within your residence.':
        'échanger des services au sein de votre résidence.',

    '1. Information we collect': '1. Informations que nous collectons',
    'Hands may collect information you provide when creating ':
        'Hands peut collecter les informations que vous fournissez lors de la création de ',
    'your account, such as your username, email address, ':
        'votre compte, telles que votre nom d’utilisateur, votre adresse e-mail, ',
    'residence, profile picture, and bio. Content you publish, ':
        'votre résidence, votre photo de profil et votre biographie. Le contenu que vous publiez, ',
    'including posts, comments, and media, may also be stored ':
        'notamment les publications, les commentaires et les fichiers multimédias, peut également être stocké ',
    'to provide the app services.':
        'afin de fournir les services de l’application.',

    '2. Residence-based access': '2. Accès basé sur la résidence',
    'Hands is designed to connect students within their ':
        'Hands est conçue pour mettre en relation les étudiants au sein de leur ',
    'residence. Your residence information is used to help ':
        'résidence. Les informations relatives à votre résidence sont utilisées pour ',
    'provide residence-based features. This does not mean ':
        'fournir des fonctionnalités adaptées à votre résidence. Cela ne signifie pas que ',
    'every piece of your personal information is visible ':
        'toutes vos informations personnelles sont visibles ',
    'to every resident.': 'par tous les résidents.',

    '3. Messages and communication': '3. Messages et communications',
    'Hands allows users from the same residence to communicate through messages. ':
        'Hands permet aux utilisateurs  de la même résidence de communiquer par messages. ',
    'Messages are intended for the relevant conversation ':
        'Les messages sont destinés aux participants de la conversation concernée. ',
    'participants. Do not share passwords, financial details, ':
        'Ne partagez pas de mots de passe, de coordonnées financières ',
    'or other sensitive information in chats. Only describe ':
        'ou d’autres informations sensibles dans les discussions. Ne présentez les ',
    'messages as private or encrypted.': 'messages comme privés ou chiffrés.',

    '4. Posts and profile information':
        '4. Publications et informations du profil',
    'Information you publish on your profile or in posts may ':
        'Les informations que vous publiez sur votre profil ou dans vos publications peuvent ',
    'be visible to other users who are permitted to access it. ':
        'être visibles par les utilisateurs autorisés à y accéder. ',
    'Think carefully before publishing personal details or ':
        'Réfléchissez bien avant de publier des informations personnelles ou',
    'uploading photos and videos.':
        'de mettre en ligne des photos et des vidéos.',

    '5. Blocking and reporting': '5. Blocage et signalement',
    'You can use available blocking features to limit ':
        'Vous pouvez utiliser les fonctionnalités de blocage disponibles pour limiter ',
    'interactions with specific accounts. Reports may be ':
        'les interactions avec certains comptes. Les signalements peuvent être ',
    'reviewed to help address inappropriate content or ':
        'examinés afin de traiter les contenus ou les comportements ',
    'behavior. Blocking should not be treated as a guarantee ':
        'inappropriés. Le blocage ne garantit pas que ',
    'that all previous interactions or content are erased.':
        'toutes les interactions ou tous les contenus antérieurs seront supprimés.',

    '6. Data security': '6. Sécurité des données',
    'We use technical and organizational measures intended ':
        'Nous mettons en œuvre des mesures techniques et organisationnelles destinées à ',
    'to protect account information. No online service can ':
        'protéger les informations des comptes. Aucun service en ligne ne peut ',
    'guarantee absolute security. Keep your login credentials ':
        'garantir une sécurité absolue. Conservez vos identifiants de connexion ',
    'safe and report suspicious activity.':
        'en sécurité et signalez toute activité suspecte.',

    '7. Storage and service providers':
        '7. Stockage et prestataires de services',
    'Information may be processed by the service providers ':
        'Les informations peuvent être traitées par les prestataires de services ',
    'needed to operate Hands, such as database, media storage, ':
        'nécessaires au fonctionnement de Hands, notamment les fournisseurs de bases de données et de stockage multimédia, ',
    'authentication, and payment providers, where applicable. ':
        'ainsi que les fournisseurs de services d’authentification et de paiement, le cas échéant. ',
    'The final policy should identify the providers actually ':
        'La version définitive de cette politique doit identifier les prestataires réellement ',
    'used and explain their relevant roles.':
        'utilisés et expliquer leurs rôles respectifs.',

    '8. Your choices and your data': '8. Vos choix et vos données',
    'You can manage information through the settings and ':
        'Vous pouvez gérer vos informations à l’aide des paramètres et des ',
    'features available in Hands. You may request access to, ':
        'fonctionnalités disponibles dans Hands. Vous pouvez demander l’accès à vos données personnelles, ',
    'correction of, or deletion of your personal information, ':
        'leur rectification ou leur suppression, ',
    'subject to applicable law and legitimate retention ':
        'sous réserve du droit applicable et des obligations légitimes de conservation ',
    'requirements. Add your actual account-deletion process ':
        'des données. Ajoutez la procédure réelle de suppression de compte ',
    'and contact details before publishing this policy.':
        'ainsi que les coordonnées de contact avant de publier cette politique.',

    '9. Age requirements': '9. Conditions d’âge',
    'Hands is intended for its eligible student audience. ':
        'Hands est destinée aux étudiants remplissant les conditions d’accès. ',
    'The app should apply and communicate its actual minimum ':
        'L’application doit appliquer et communiquer clairement son âge minimum ',
    'age requirements and comply with the laws applicable ':
        'requis et respecter les lois applicables ',
    'to its users.': 'à ses utilisateurs.',

    '10. Changes to this policy': '10. Modifications de cette politique',
    'This policy may be updated when Hands changes its ':
        'Cette politique peut être mise à jour lorsque Hands modifie ses ',
    'features or legal requirements change. When appropriate, ':
        'fonctionnalités ou lorsque les exigences légales évoluent. Le cas échéant, ',
    'users will be informed of significant changes.':
        'les utilisateurs seront informés des modifications importantes.',

    '11. Contact us': '11. Nous contacter',
    'For questions about this policy or your personal ':
        'Pour toute question concernant cette politique ou vos ',
    'information, contact the Hands team at the official ':
        'informations personnelles, contactez l’équipe Hands à l’adresse e-mail officielle ',
    'privacy email address @@@@@@@@@2@@@@@@@':
        'dédiée à la confidentialité @@@@@@@@@2@@@@@@@',
    'Hands - To survive in your residence.':
        'Hands - Pour survivre dans ta résidence.',

    'Terms of Service': 'Conditions d’utilisation',
    'Welcome to Hands!': 'Bienvenue sur Hands !',
    'Read the rules and conditions for using Hands ':
        'Lisez les règles et les conditions d’utilisation de Hands ',
    'to connect with students, offer services, ':
        'pour vous connecter avec les étudiants et proposer des services, ',
    'and exchange help within your residence.':
        'et échanger de l’aide au sein de votre résidence.',
    'Hands connects students living in the ':
        'Hands met en relation les étudiants vivant dans la ',
    'same residence to share services, ':
        'même résidence afin de partager des services, ',
    'offer skills, and help each other.':
        'de proposer leurs compétences et de s’entraider.',

    '1. Acceptance of Terms': '1. Acceptation des conditions',
    'By creating an account or using Hands, you agree ':
        'En créant un compte ou en utilisant Hands, vous acceptez ',
    'to follow these Terms of Service and applicable ':
        'de respecter les présentes conditions d’utilisation ainsi que les lois ',
    'laws. If you do not agree, please stop using ':
        'applicables. Si vous n’acceptez pas ces conditions, veuillez cesser d’utiliser ',
    'the platform.': 'la plateforme.',

    '2. Eligibility and Accounts': '2. Conditions d’accès et comptes',
    'Hands is designed for students within participating ':
        'Hands est destinée aux étudiants des ',
    'student residences. You must provide accurate ':
        'résidences universitaires participantes. Vous devez fournir des informations exactes, ',
    'information, keep your account credentials secure, ':
        'protéger vos identifiants de connexion ',
    'and not impersonate another person or create ':
        'et ne pas usurper l’identité d’une autre personne ni créer ',
    'fraudulent accounts.': 'de comptes frauduleux.',

    '3. Posts and Services': '3. Publications et services',
    'You are responsible for the content you publish ':
        'Vous êtes responsable du contenu que vous publiez ',
    'and the services you offer. Posts must be accurate, ':
        'et des services que vous proposez. Vos publications doivent être exactes, ',
    'respectful, and lawful. Do not publish misleading ':
        'respectueuses et conformes à la loi. Ne publiez pas d’offres trompeuses, ',
    'offers, prohibited content, spam, or services ':
        'de contenu interdit, de spam ou de services ',
    'that could endanger other students.':
        'susceptibles de mettre en danger d’autres étudiants.',

    '4. Communication and Conduct': '4. Communication et comportement',
    'Treat other users respectfully. Harassment, threats, ':
        'Traitez les autres utilisateurs avec respect. Le harcèlement, les menaces, ',
    'fraud, discrimination, impersonation, and misuse ':
        'la fraude, la discrimination, l’usurpation d’identité et l’utilisation abusive ',
    'of private information are not permitted. You may ':
        'd’informations privées sont interdits. Vous pouvez ',
    'block or report users who violate these rules.':
        'bloquer ou signaler les utilisateurs qui enfreignent ces règles.',

    '5. Transactions and Payments': '5. Transactions et paiements',
    'Users are responsible for agreeing on service ':
        'Les utilisateurs sont responsables de convenir des modalités du service, ',
    'details, prices, delivery, and payment arrangements. ':
        'des prix, de la livraison et des modalités de paiement. ',
    'Hands does not guarantee the quality, completion, ':
        'Hands ne garantit ni la qualité, ni la réalisation, ',
    'or outcome of services offered by other users. ':
        'ni le résultat des services proposés par les autres utilisateurs. ',
    'Any paid post-credit purchases are subject to ':
        'tout achat de crédits de publication est soumis ',
    'the prices and conditions displayed at purchase.':
        'aux prix et aux conditions affichés au moment de l’achat.',

    '6. Free Posts and Paid Credits':
        '6. Publications gratuites et crédits payants',
    'Hands may provide a limited number of free posts (3) ':
        'Hands peut proposer un nombre limité de publications gratuites (3) ',
    'and offer additional posting credits for purchase. ':
        'et permettre l’achat de crédits de publication supplémentaires. ',
    'Available allowances, prices, and applicable ':
        'es quotas disponibles, les prix et les ',
    'conditions will be displayed in the app. Do not ':
        'conditions applicables seront affichés dans l’application. N’essayez pas ',
    'attempt to bypass posting limits or manipulate ':
        'de contourner les limites de publication ni de manipuler ',
    'payment confirmations.': 'les confirmations de paiement.',

    '7. Privacy and Safety': '7. Confidentialité et sécurité',
    'Use other students’ personal information only ':
        'N’utilisez les informations personnelles des autres étudiants que ',
    'for legitimate purposes related to the platform. ':
        'dans le cadre d’usages légitimes liés à la plateforme. ',
    'Do not share private messages, contact details, ':
        'Ne partagez pas de messages privés, de coordonnées ',
    'or other personal information without appropriate ':
        'ni d’autres informations personnelles sans autorisation ',
    'permission. Review our Privacy Policy to understand ':
        'appropriée. Consultez notre politique de confidentialité pour comprendre ',
    'how personal information is handled.':
        'comment les informations personnelles sont traitées.',

    '8. Reporting and Account Restrictions':
        '8. Signalements et restrictions de compte',
    'Hands may review reported content and take ':
        'Hands peut examiner les contenus signalés et prendre ',
    'appropriate action against accounts that violate ':
        'les mesures appropriées à l’encontre des comptes qui enfreignent ',
    'these terms, including removing posts, restricting ':
        'ces conditions, notamment en supprimant des publications, en limitant certaines ',
    'features, or suspending accounts, where appropriate.':
        'fonctionnalités ou en suspendant des comptes, si nécessaire.',

    '9. Service Availability': '9. Disponibilité du service',
    'We aim to keep Hands available and functioning ':
        'Nous nous efforçons de maintenir Hands disponible et fonctionnelle ',
    'properly, but uninterrupted access is not ':
        'correctement, mais un accès ininterrompu n’est pas ',
    'guaranteed. Features may be updated, changed, ':
        'garanti. Les fonctionnalités peuvent être mises à jour, modifiées ',
    'or temporarily unavailable.': 'ou temporairement indisponibles.',

    '10. Changes to These Terms': '10. Modifications des présentes conditions',
    'These terms may be updated as Hands evolves. ':
        'Ces conditions peuvent être mises à jour à mesure que Hands évolue. ',
    'Material changes should be communicated through ':
        'les modifications importantes doivent être communiquées par des moyens ',
    'appropriate channels. Continued use after updated ':
        'appropriés. La poursuite de l’utilisation après l’entrée en vigueur des nouvelles ',
    'terms take effect may be subject to those terms, ':
        'conditions peut impliquer l’acceptation de celles-ci, ',
    'as permitted by applicable law.':
        'dans la mesure autorisée par la loi applicable.',

    '11. Contact Us': '11. Nous contacter',
    'If you have questions about these terms, contact ':
        'Si vous avez des questions concernant ces conditions, contactez ',
    'the Hands team through the official support ':
        'l’équipe Hands via le canal officiel d’assistance ',
    'channel provided in the app.': 'mis à disposition dans l’application.',

    'Help & Support': 'Aide et assistance',
    'How can we help you?': 'Comment pouvons-nous vous aider ?',
    'Find answers to common questions or get help ':
        'Trouvez des réponses aux questions fréquentes ou obtenez de l’aide ',
    'with your Hands account and services within your residence.':
        'obtenez de l’aide concernant votre compte Hands.',
    'Frequently asked questions :': 'Questions fréquentes :',
    'What is Hands?': 'Qu’est-ce que Hands ?',
    'Hands is a social marketplace designed for students living ':
        'Hands est une plateforme sociale d’échange de services destinée aux étudiants vivant ',
    'in the same residence. It combines social media features ':
        'dans la même résidence. Elle combine des fonctionnalités de réseau social ',
    'with a platform where students can offer services, discover ':
        'avec une plateforme sur laquelle les étudiants peuvent proposer des services, découvrir ',
    'what others provide, connect through messages, and support ':
        'ce que les autres proposent, communiquer par messages et soutenir ',
    'their student community.': 'leur communauté étudiante.',

    'Why can I only see certain posts?':
        'Pourquoi ne vois-je que certaines publications ?',
    'Posts are intended for students in your residence. ':
        'Les publications sont destinées aux étudiants de votre résidence. ',
    'Make sure your account is associated with the ':
        'assurez-vous que votre compte est associé à la ',
    'correct residence.': 'bonne résidence.',

    'How can I publish a post?': 'Comment publier une publication ?',
    'Open the create-post screen, add your service ':
        'Ouvrez l’écran de création de publication, ajoutez les informations concernant votre service ',
    'details and media, then follow the instructions ':
        'ainsi que les fichiers multimédias, puis suivez les instructions ',
    'to publish. Posting allowances and any applicable ':
        'pour publier. Les quotas de publication et les éventuelles ',
    'credit requirements are shown in the app.':
        'conditions liées aux crédits sont indiqués dans l’application. ',

    'Why can’t I publish another post?':
        'Pourquoi ne puis-je pas publier une autre publication ?',
    'You may have used your free posting allowance ':
        'Vous avez peut-être épuisé votre quota de publications gratuites ',
    'and may need additional post credits. Check the ':
        'et devez peut-être acheter des crédits supplémentaires. Consultez la section ',
    'credits section in your profile.': 'crédits de votre profil.',

    'How do I block or report someone?':
        'Comment bloquer ou signaler quelqu’un ?',
    'Open the relevant profile or post and use the ':
        'Ouvrez le profil ou la publication concernée et utilisez l’option ',
    'available block or report option. If someone ':
        'de blocage ou de signalement disponible. Si quelqu’un ',
    'makes you feel unsafe, avoid sharing personal ':
        'vous met mal à l’aise ou vous fait vous sentir en danger, évitez de partager des informations personnelles ',
    'information and contact support.': 'et contactez l’assistance.',

    'How can I edit my profile?': 'Comment modifier mon profil ?',
    'Open your profile and use the available profile ':
        'Ouvrez votre profil et utilisez l’option de modification ',
    'editing option to update your username, bio, ':
        'disponible pour mettre à jour votre nom d’utilisateur, votre biographie ',
    'or profile picture.': 'ou votre photo de profil.',
    'Still need help?': 'Besoin d’aide supplémentaire ?',
    'Choose an option below to get assistance.':
        'Choisissez une option ci-dessous pour obtenir de l’aide.',
    'Log out?': 'Se déconnecter?',
    'Are you sure you want to log out of your Hands account?':
        'Voulez-vous vraiment vous déconnecter de votre compte Hands ?',
    'Cancle': 'Cancle',
    'Log out': 'Se déconnecter',
    'Delete account?': 'Supprimer le compte ?',
    'Delete account': 'Supprimer le compte',
    'Are you sure you want to permanently ':
        'Voulez-vous vraiment supprimer définitivement ',
    'delete your Hands account? This action ':
        'supprimer votre compte Hands ? Cette action ',
    'This action cannot be undone.': 'Cette action ne peut pas être annulée.',
    'cannot be undone.': ' est irréversible.',
    'No posts yet. Be the first who post!':
        'Aucune publication pour le moment. Soyez le premier à publier !',
    'No posts yet': 'Aucune publication pour le moment',
    'No posts found for ': 'Aucune publication trouvée pour ',
    'Send message': 'Envoyer un message',
    'Share profile': 'Partager le profil',
    'Block account': 'Bloquer le compte',
    'Report account': 'Signaler le compte',
    'Why are you reporting this post?':
        'Pourquoi signalez-vous cette publication ?',
    'Inappropriate content': 'Contenu inapproprié',
    'Scam or fraud': 'Arnaque ou fraude',
    'Spam or fake account': 'Spam ou faux compte',
    'Harassment or bullying': 'Harcèlement ou intimidation',
    'Pretending to be someone else': 'Usurpation d’identité',
    'Submit report': 'Envoyer le signalement',
    'Additional details (optional)': 'Détails supplémentaires (facultatif)',
    'Start the conversation!': 'Commencez la conversation !',
    'Send the first message to your group.':
        'Envoyez le 1 er message à votre groupe.',
    'Message your group...': 'Écrivez un message à votre groupe...',
    'Tell students a little about yourself !':
        'Parlez un peu de vous aux étudiants !',
    'Please select your Wilaya and residence.':
        'Veuillez sélectionner votre wilaya et votre résidence.',
    'Bio cannot exceed 300 characters.':
        'La biographie ne peut pas dépasser 300 caractères.',
    'Get help with an account or a problem':
        'Obtenez de l’aide concernant votre compte ou un problème',
  },

  'ar': {
    'Home': 'الرئيسية',
    'Search': 'البحث',
    'Explore': 'استكشاف',
    'Messages': 'الرسائل',
    'Profile': 'الملف الشخصي',
    'Settings': 'الإعدادات',
    'Language': 'اللغة',
    'Choose language': 'اختر لغة',
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
    'Exchange': 'تبادل',
    'Projects': 'المشاريع',
    'Programming': 'البرمجة',
    'Trips': 'الرحلات',
    'Lost & Found': 'المفقودات والموجودات',
    'Rentals & Borrowing': 'الكراء والاستعارة',
    'Questions & Answers': 'الأسئلة والأجوبة',
    'Other': 'أخرى',
    'Cancel': 'إلغاء',
    'Save': 'حفظ',
    'Delete': 'حذف',
    'Report': 'إبلاغ',
    'Followed': 'تتابعه',
    'Follow': 'متابعة',
    'No Posts': 'لا توجد منشورات بعد',
    'Search Hint': 'اكتشف الخدمات في إقامتك الجامعية',
    'Edit post': 'تعديل المنشور',
    'Delete post?': 'حذف المنشور',
    'Delete post': 'حذف المنشور',
    'Report post': 'الإبلاغ عن المنشور',
    'Block user': 'حظر المستخدم',
    'Block user?': 'حظر المستخدم',
    'Block': 'حظر',
    ' has been blocked.': ' تم حظره.',
    'Reply to ': 'الرد على ',
    'Comments': 'التعليقات',
    'No comments yet. Be the first !': 'لا توجد تعليقات. كن أول من يعلّق!',
    'Write a comment...': 'اكتب تعليقًا',
    'Write a reply...': ' ...اكتب ردا',
    'Edit comment': 'تعديل تعليق',
    'Delete reply?': ' ?حذف تعليق',
    'Delete comment?': 'هل تريد حذف التعليق؟',
    'Edit reply': 'تعديل الرد',
    'Edit': 'تعديل',
    'Reply': 'رد',
    'No posts about': 'لا توجد منشورات حول',
    'yet.': 'بعد.',
    'Report user': 'الإبلاغ عن المستخدم',
    'Posts': 'المنشورات',
    'Users': 'المستخدمون',
    'Groups': 'المجموعات',
    'Create a post': 'إنشاء منشور',
    'Create group': 'إنشاء مجموعة',
    'Share your service with your residence !':
        'شارك خدمتك مع المقيمين في إقامتك!',
    'Category': 'الفئة',
    'Caption': 'الوصف',
    'Describe your service...': 'صف خدمتك...',
    'Search ...': '...بحث',
    'Add photos or videos': 'أضف صورًا أو مقاطع فيديو',
    'Publish post': 'نشر',
    'Caption is required': 'الوصف مطلوب',
    'Search people or groups': 'ابحث عن أشخاص أو مجموعات',
    'Direct messages': 'الرسائل المباشرة',
    'Text ': ' راسل ',
    'Mode': 'الوضع',
    'Create a group': 'إنشاء مجموعة',
    'Group name': 'اسم المجموعة',
    'student(s) selected': 'الطالب (أو الطلاب) المختارون',
    'Search users': 'البحث عن المستخدمين',
    'Following': 'أتابعهم',
    'Followers': 'المتابعون',
    'You don’t have any followers yet.': 'ليس لديك أي متابعين حتى الآن.',
    'You aren’t following anyone yet.': 'أنت لا تتابع أي شخص حتى الآن.',
    'Why are you reporting this user?': 'لماذا تريد الإبلاغ عن هذا المستخدم؟',
    'Replies': 'الردود',
    'Post Credits': 'رصيد المنشورات',
    'Your balance': 'رصيدك',
    'Keep track of the posts you can publish.':
        'تابع عدد المنشورات التي يمكنك نشرها',
    'Free posts left': 'المنشورات المجانية المتبقية',
    'Paid post credits': 'رصيد المنشورات المدفوع',
    'Get more post credits': 'احصل على رصيد إضافي',
    'Choose the package that works for you !': 'اختر الباقة المناسبة لك!',
    '5 Post credits': 'رصيد 5 منشورات',
    '50 DA': '50 دج',
    'For who is just getting started.': 'لمن بدأوا للتو',
    'DA / post': 'دج لكل منشور',
    'Buy package': 'شراء الباقة',
    '10 Post credits': 'رصيد 10 منشورات',
    'For who wants to do more.': 'لمن يريدون إنجاز المزيد',
    '90 DA': '90 دج',
    'Are you sure you want to leave this group?':
        'هل أنت متأكد أنك تريد مغادرة هذه المجموعة؟',
    'Leave': 'مغادرة',
    '20 Post credits': 'رصيد 20 منشورًا',
    'For who never stop creating.': 'لمن لا يتوقفون عن الإبداع',
    '170 DA': '170 دج',
    'Profile options': 'خيارات الملف الشخصي',
    'Your 3 free posts are used first. Purchased credits are available after your free posts have been used.':
        'تُستخدم منشوراتك المجانية الثلاثة أولًا، ويصبح رصيد المنشورات الذي اشتريته متاحًا بعد نفاد المنشورات المجانية.',
    'Edit profile': 'تعديل الملف الشخصي',
    'Personal information': 'المعلومات الشخصية',
    'Username': 'اسم المستخدم',
    'Bio': 'نبذة تعريفية',
    'Location': 'الموقع',
    'Save changes': 'حفظ التغييرات',
    'Update your service details': 'حدّث تفاصيل خدمتك',
    'Existing media': 'الوسائط الحالية',
    'New media': 'وسائط جديدة',
    'Followers & Following': 'المتابعون والمتابَعون',
    'Are you sure you want to block': 'هل أنت متأكد أنك تريد حظر',
    'Their posts will no longer appear in your feed.':
        'لن تظهر منشوراته بعد الآن في صفحتك الرئيسية.',
    'Remove follower?': 'إزالة المتابع؟',
    'Followings': 'أتابعهم',
    'Are you sure you want to remove': 'هل أنت متأكد أنك تريد إزالة',
    'from your followers?': 'من قائمة متابعيك؟',
    'Remove': 'إزالة',
    'remove': 'إزالة',
    'Unfollow user?': 'إلغاء متابعة المستخدم',
    'unfollow': ' إلغاء متابعة',
    'Are you sure you want to': 'هل أنت متأكد أنك تريد',
    'Are you sure you want to delete this post? This action cannot be undone.':
        'هل أنت متأكد أنك تريد حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',
    'Confirm': 'تأكيد',
    'Choose display mode': 'اختر وضع العرض',
    'Light': 'فاتح',
    'Dark': 'داكن',
    'Blocked accounts': 'الحسابات المحظورة',
    'No blocked accounts': 'لا توجد حسابات محظورة',
    'Leave group': 'مغادرة المجموعة',
    'Leave group?': 'مغادرة المجموعة?',
    'Unblock account?': 'إلغاء حظر الحساب؟',
    'Are you sure you want to unblock': 'هل أنت متأكد أنك تريد إلغاء حظر',
    'Unblock': 'إلغاء الحظر',
    'Privacy Policy': 'سياسة الخصوصية',
    'Your privacy matters': 'خصوصيتك مهمة',
    'Learn how Hands handles your information when ':
        'تعرّف على كيفية تعامل تطبيق Hands مع معلوماتك عند ',
    'you use the app to connect with students and ':
        'استخدامك التطبيق للتواصل مع الطلبة و',
    'exchange services within your residence.':
        'تبادل الخدمات داخل إقامتك الجامعية.',
    '1. Information we collect': '1. المعلومات التي نجمعها',
    'Hands may collect information you provide when creating ':
        'قد يجمع تطبيق Hands المعلومات التي تقدمها عند إنشاء ',
    'your account, such as your username, email address, ':
        'حسابك، مثل اسم المستخدم وعنوان البريد الإلكتروني و',
    'residence, profile picture, and bio. Content you publish, ':
        'الإقامة الجامعية وصورة الملف الشخصي والنبذة التعريفية. وقد يُحفظ أيضًا المحتوى الذي تنشره، مثل ',
    'including posts, comments, and media, may also be stored ':
        'المنشورات والتعليقات والوسائط، ',
    'to provide the app services.': 'لتوفير خدمات التطبيق.',
    '2. Residence-based access': '2. الوصول حسب الإقامة الجامعية',
    'Hands is designed to connect students within their ':
        'صُمّم تطبيق Hands لربط الطلبة داخل ',
    'residence. Your residence information is used to help ':
        'إقامتهم الجامعية. وتُستخدم معلومات إقامتك للمساعدة في ',
    'provide residence-based features. This does not mean ':
        'توفير الميزات المرتبطة بالإقامة. ولا يعني ذلك أن ',
    'every piece of your personal information is visible ':
        'كل معلوماتك الشخصية تكون مرئية ',
    'to every resident.': 'لجميع المقيمين.',
    '3. Messages and communication': '3. الرسائل والتواصل',
    'Hands allows users from the same residence to communicate through messages. ':
        'يتيح تطبيق Hands للمستخدمين من نفس الإقامة التواصل عبر الرسائل. ',
    'Messages are intended for the relevant conversation ':
        'الرسائل مخصّصة للمشاركين في المحادثة المعنية. ',
    'participants. Do not share passwords, financial details, ':
        'لا تشارك كلمات المرور أو التفاصيل المالية أو ',
    'or other sensitive information in chats. Only describe ':
        'أي معلومات حساسة أخرى في المحادثات. ولا تصف ',
    'messages as private or encrypted.': 'الرسائل بأنها خاصة أو مشفّرة .',

    '4. Posts and profile information': '4. المنشورات ومعلومات الملف الشخصي',
    'Information you publish on your profile or in posts may ':
        'قد تكون المعلومات التي تنشرها في ملفك الشخصي أو منشوراتك ',
    'be visible to other users who are permitted to access it. ':
        'مرئية للمستخدمين الآخرين المسموح لهم بالاطلاع عليها. ',
    'Think carefully before publishing personal details or ':
        'فكّر جيدًا قبل نشر التفاصيل الشخصية أو',
    'uploading photos and videos.': 'تحميل الصور ومقاطع الفيديو.',
    '5. Blocking and reporting': '5. الحظر والإبلاغ',
    'You can use available blocking features to limit ':
        'يمكنك استخدام ميزات الحظر المتاحة للحد من ',
    'interactions with specific accounts. Reports may be ':
        'التفاعل مع حسابات محددة. وقد تتم مراجعة البلاغات ',
    'reviewed to help address inappropriate content or ':
        'للمساعدة في معالجة المحتوى أو السلوك غير المناسب. ',
    'behavior. Blocking should not be treated as a guarantee ':
        'ولا ينبغي اعتبار الحظر ضمانًا ',
    'that all previous interactions or content are erased.':
        'لمحو جميع التفاعلات أو المحتويات السابقة.',
    '6. Data security': '6. أمن البيانات',
    'We use technical and organizational measures intended ':
        'نستخدم تدابير تقنية وتنظيمية تهدف إلى ',
    'to protect account information. No online service can ':
        'حماية معلومات الحساب. ولا يمكن لأي خدمة عبر الإنترنت ',
    'guarantee absolute security. Keep your login credentials ':
        'ضمان الأمان المطلق. حافظ على بيانات تسجيل الدخول ',
    'safe and report suspicious activity.': 'آمنة وأبلغ عن أي نشاط مشبوه.',
    '7. Storage and service providers': '7. التخزين ومقدمو الخدمات',
    'Information may be processed by the service providers ':
        'قد تتم معالجة المعلومات من قِبل مقدمي الخدمات ',
    'needed to operate Hands, such as database, media storage, ':
        'اللازمين لتشغيل Hands، مثل خدمات قواعد البيانات وتخزين الوسائط و',
    'authentication, and payment providers, where applicable. ':
        'المصادقة والدفع، عند الاقتضاء. ',
    'The final policy should identify the providers actually ':
        'ينبغي أن تحدد سياسة الخصوصية النهائية مقدمي الخدمات الذين ',
    'used and explain their relevant roles.':
        'يُستخدمون فعليًا وأن توضح أدوارهم.',
    '8. Your choices and your data': '8. خياراتك وبياناتك',
    'You can manage information through the settings and ':
        'يمكنك إدارة معلوماتك من خلال الإعدادات والميزات ',
    'features available in Hands. You may request access to, ':
        'المتاحة في Hands. ويمكنك طلب الوصول إلى معلوماتك الشخصية أو ',
    'correction of, or deletion of your personal information, ':
        'تصحيحها أو حذفها، ',
    'subject to applicable law and legitimate retention ':
        'وفقًا للقوانين المعمول بها ومتطلبات الاحتفاظ المشروعة. ',
    'requirements. Add your actual account-deletion process ':
        'أضف طريقة حذف الحساب المعتمدة فعليًا ',
    'and contact details before publishing this policy.':
        'وتفاصيل التواصل قبل نشر هذه السياسة.',
    '9. Age requirements': '9. متطلبات العمر',
    'Hands is intended for its eligible student audience. ':
        'تطبيق Hands مخصّص لفئة الطلبة المستوفين لشروط الاستخدام. ',
    'The app should apply and communicate its actual minimum ':
        'ينبغي للتطبيق تطبيق الحد الأدنى الفعلي للعمر والإعلان عنه، ',
    'age requirements and comply with the laws applicable ':
        'والامتثال للقوانين المعمول بها ',
    'to its users.': 'على مستخدميه.',
    '10. Changes to this policy': '10. التعديلات على هذه السياسة',
    'This policy may be updated when Hands changes its ':
        'قد تُحدّث هذه السياسة عند تغيير ',
    'features or legal requirements change. When appropriate, ':
        'ميزات Hands أو تغيّر المتطلبات القانونية. وعند الاقتضاء، ',
    'users will be informed of significant changes.':
        'سيتم إبلاغ المستخدمين بالتغييرات المهمة.',
    '11. Contact us': '11. اتصل بنا',
    'For questions about this policy or your personal ':
        'للاستفسارات حول هذه السياسة أو معلوماتك الشخصية، ',
    'information, contact the Hands team at the official ':
        'تواصل مع فريق Hands عبر عنوان البريد الإلكتروني الرسمي ',
    'privacy email address @@@@@@@@@2@@@@@@@.':
        'المخصّص للخصوصية والمنشور @@@@@@@@@2@@@@@@@ق.',
    'Hands - To survive in your residence.': 'Hands - لي تنجو في إقامتك',
    'Terms of Service': 'شروط الاستخدام',
    'Welcome to Hands!': 'مرحبًا بك في Hands!',
    'Read the rules and conditions for using Hands ':
        'اقرأ القواعد والشروط الخاصة باستخدام Hands ',
    'to connect with students, offer services, ':
        'للتواصل مع الطلاب وتقديم الخدمات، ',
    'and exchange help within your residence.': 'وتبادل المساعدة داخل إقامتك.',
    'Hands connects students living in the ':
        'يربط تطبيق Hands الطلبة المقيمين في ',
    'same residence to share services, ':
        'الإقامة الجامعية نفسها لتبادل الخدمات و',
    'offer skills, and help each other.': 'عرض مهاراتهم ومساعدة بعضهم بعضًا.',
    '1. Acceptance of Terms': '1. الموافقة على الشروط',
    'By creating an account or using Hands, you agree ':
        'بإنشاء حساب أو استخدام Hands، فإنك توافق ',
    'to follow these Terms of Service and applicable ':
        'على الالتزام بشروط الاستخدام هذه والقوانين ',
    'laws. If you do not agree, please stop using ':
        'المعمول بها. إذا لم توافق عليها، فيُرجى التوقف عن استخدام ',
    'the platform.': 'المنصة.',
    '2. Eligibility and Accounts': '2. الأهلية والحسابات',
    'Hands is designed for students within participating ':
        'صُمّم Hands للطلبة في ',
    'student residences. You must provide accurate ':
        'الإقامات الجامعية المشاركة. يجب عليك تقديم معلومات صحيحة، ',
    'information, keep your account credentials secure, ':
        'والحفاظ على سرية بيانات حسابك، ',
    'and not impersonate another person or create ':
        'وعدم انتحال شخصية أي شخص آخر أو إنشاء ',
    'fraudulent accounts.': 'حسابات احتيالية.',
    '3. Posts and Services': '3. المنشورات والخدمات',
    'You are responsible for the content you publish ':
        'أنت مسؤول عن المحتوى الذي تنشره ',
    'and the services you offer. Posts must be accurate, ':
        'والخدمات التي تقدمها. يجب أن تكون المنشورات دقيقة، ',
    'respectful, and lawful. Do not publish misleading ':
        'ومحترمة ومتوافقة مع القانون. لا تنشر عروضًا مضللة أو ',
    'offers, prohibited content, spam, or services ':
        'محتوى محظورًا أو رسائل مزعجة أو خدمات ',
    'that could endanger other students.': 'قد تعرّض الطلبة الآخرين للخطر.',
    '4. Communication and Conduct': '4. التواصل والسلوك',
    'Treat other users respectfully. Harassment, threats, ':
        'تعامل مع المستخدمين الآخرين باحترام. يُمنع التحرش والتهديد و',
    'fraud, discrimination, impersonation, and misuse ':
        'الاحتيال والتمييز وانتحال الشخصية وإساءة استخدام ',
    'of private information are not permitted. You may ':
        'المعلومات الخاصة. ويمكنك ',
    'block or report users who violate these rules.':
        'حظر المستخدمين الذين يخالفون هذه القواعد أو الإبلاغ عنهم.',
    '5. Transactions and Payments': '5. المعاملات والمدفوعات',
    'Users are responsible for agreeing on service ':
        'يتحمل المستخدمون مسؤولية الاتفاق على تفاصيل الخدمة ',
    'details, prices, delivery, and payment arrangements. ':
        'وأسعارها وطريقة تسليمها وترتيبات الدفع. ',
    'Hands does not guarantee the quality, completion, ':
        'لا يضمن Hands جودة الخدمات التي يقدمها المستخدمون الآخرون أو إتمامها ',
    'or outcome of services offered by other users. ':
        'أو النتائج المترتبة عليها. ',
    'Any paid post-credit purchases are subject to ':
        'تخضع جميع عمليات شراء أرصدة المنشورات المدفوعة لـ',
    'the prices and conditions displayed at purchase.':
        'الأسعار والشروط المعروضة عند الشراء.',
    '6. Free Posts and Paid Credits': '6. المنشورات المجانية والأرصدة المدفوعة',
    'Hands may provide a limited number of free posts (3) ':
        'قد يوفّر Hands عددًا محدودًا من المنشورات المجانية (3) ',
    'and offer additional posting credits for purchase. ':
        'ويتيح شراء أرصدة إضافية للنشر. ',
    'Available allowances, prices, and applicable ':
        'سيتم عرض الحدود المتاحة والأسعار والشروط ',
    'conditions will be displayed in the app. Do not ':
        'المطبقة داخل التطبيق. لا تحاول ',
    'attempt to bypass posting limits or manipulate ':
        'تجاوز حدود النشر أو التلاعب ',
    'payment confirmations.': 'بتأكيدات الدفع.',
    '7. Privacy and Safety': '7. الخصوصية والسلامة',
    'Use other students’ personal information only ':
        'استخدم المعلومات الشخصية للطلبة الآخرين فقط ',
    'for legitimate purposes related to the platform. ':
        'لأغراض مشروعة مرتبطة بالمنصة. ',
    'Do not share private messages, contact details, ':
        'لا تشارك الرسائل الخاصة أو بيانات الاتصال ',
    'or other personal information without appropriate ':
        ' أو أي معلومات شخصية أخرى دون الحصول على',
    'permission. Review our Privacy Policy to understand ':
        ' الإذن المناسب. راجع سياسة الخصوصية لفهم ',
    'how personal information is handled.':
        'كيفية التعامل مع المعلومات الشخصية.',
    '8. Reporting and Account Restrictions': '8. الإبلاغ وقيود الحساب',
    'Hands may review reported content and take ':
        'قد يراجع Hands المحتوى المبلّغ عنه ويتخذ ',
    'appropriate action against accounts that violate ':
        'الإجراءات المناسبة بحق الحسابات التي تخالف ',
    'these terms, including removing posts, restricting ':
        'هذه الشروط، بما في ذلك حذف المنشورات أو تقييد ',
    'features, or suspending accounts, where appropriate.':
        'الميزات أو تعليق الحسابات عند الاقتضاء.',
    '9. Service Availability': '9. توفر الخدمة',
    'We aim to keep Hands available and functioning ':
        'نسعى إلى إبقاء Hands متاحًا ويعمل ',
    'properly, but uninterrupted access is not ':
        'بشكل صحيح، لكن لا يمكن ضمان الوصول المستمر ',
    'guaranteed. Features may be updated, changed, ':
        'دون انقطاع. وقد تُحدّث الميزات أو تتغير ',
    'or temporarily unavailable.': 'أو تصبح غير متاحة مؤقتًا.',
    '10. Changes to These Terms': '10. التعديلات على هذه الشروط',
    'These terms may be updated as Hands evolves. ':
        'قد تُحدّث هذه الشروط مع تطور Hands. ',
    'Material changes should be communicated through ':
        'ينبغي الإعلان عن التغييرات الجوهرية عبر ',
    'appropriate channels. Continued use after updated ':
        'القنوات المناسبة. وقد يخضع استمرار الاستخدام بعد سريان ',
    'terms take effect may be subject to those terms, ':
        'الشروط المحدّثة لهذه الشروط، ',
    'as permitted by applicable law.': 'وفقًا لما يسمح به القانون المعمول به.',
    '11. Contact Us': '11. اتصل بنا',
    'If you have questions about these terms, contact ':
        'إذا كانت لديك أسئلة حول هذه الشروط، فتواصل مع ',
    'the Hands team through the official support ':
        'فريق Hands عبر قناة الدعم الرسمية ',
    'channel provided in the app.': 'المتاحة داخل التطبيق.',
    'Help & Support': 'المساعدة والدعم',
    'How can we help you?': 'كيف يمكننا مساعدتك؟',
    'Find answers to common questions or get help ':
        'اعثر على إجابات للأسئلة الشائعة أو ',
    'with your Hands account and services within your residence.':
        'احصل على المساعدة بشأن حسابك في Hands.',
    'Frequently asked questions :': 'الأسئلة الشائعة',
    'What is Hands?': 'ما هو Hands؟',
    'Hands is a social marketplace designed for students living ':
        'Hands سوق اجتماعي مخصّص للطلبة المقيمين ',
    'in the same residence. It combines social media features ':
        'في الإقامة الجامعية نفسها. يجمع بين ميزات التواصل الاجتماعي ',
    'with a platform where students can offer services, discover ':
        'ومنصة تتيح للطلبة عرض الخدمات واكتشاف ',
    'what others provide, connect through messages, and support ':
        'ما يقدمه الآخرون والتواصل عبر الرسائل ودعم ',
    'their student community.': 'مجتمعهم الطلابي.',
    'Why can I only see certain posts?': 'لماذا لا أرى سوى منشورات معينة؟',
    'Posts are intended for students in your residence. ':
        'المنشورات مخصّصة للطلبة المقيمين في إقامتك الجامعية. ',
    'Make sure your account is associated with the ': 'تأكد من ربط حسابك بـ',
    'correct residence.': 'الإقامة الجامعية الصحيحة.',
    'How can I publish a post?': 'كيف يمكنني نشر منشور؟',
    'Open the create-post screen, add your service ':
        'افتح شاشة إنشاء منشور، وأضف تفاصيل خدمتك ',
    'details and media, then follow the instructions ':
        'والوسائط، ثم اتبع التعليمات ',
    'to publish. Posting allowances and any applicable ':
        'للنشر. ستظهر حدود النشر وأي ',
    'credit requirements are shown in the app.':
        'متطلبات للأرصدة داخل التطبيق. ',
    'Why can’t I publish another post?': 'لماذا لا أستطيع نشر منشور آخر؟',
    'You may have used your free posting allowance ':
        'ربما استنفدت عدد المنشورات المجانية المتاح لك ',
    'and may need additional post credits. Check the ':
        'وقد تحتاج إلى أرصدة منشورات إضافية. تحقّق من قسم ',
    'credits section in your profile.': 'الأرصدة في ملفك الشخصي.',
    'How do I block or report someone?': 'كيف أحظر شخصًا أو أبلّغ عنه؟',
    'Open the relevant profile or post and use the ':
        'افتح الملف الشخصي أو المنشور المعني واستخدم خيار ',
    'available block or report option. If someone ':
        'الحظر أو الإبلاغ المتاح. إذا تسبب لك أحدهم في الشعور ',
    'makes you feel unsafe, avoid sharing personal ':
        'بعدم الأمان، فتجنب مشاركة معلوماتك الشخصية ',
    'information and contact support.': 'وتواصل مع الدعم.',
    'How can I edit my profile?': 'كيف أعدّل ملفي الشخصي؟',
    'Open your profile and use the available profile ':
        'افتح ملفك الشخصي واستخدم خيار تعديل الملف ',
    'editing option to update your username, bio, ':
        'لتحديث اسم المستخدم والنبذة التعريفية ',
    'or profile picture.': 'أو صورة الملف الشخصي.',
    'Still need help?': 'ما زلت بحاجة إلى المساعدة؟',
    'Choose an option below to get assistance.':
        'اختر أحد الخيارات أدناه للحصول على المساعدة.',
    'Log Out?': 'تسجيل الخروج؟',
    'Are you sure you want to log out of your Hands account?':
        'هل أنت متأكد أنك تريد تسجيل الخروج من حساب Hands؟',
    'Cancle': 'إلغاء',
    'Log out': 'تسجيل الخروج',
    'Delete account?': 'حذف الحساب؟',
    'Delete account': 'حذف الحساب',
    'Are you sure you want to permanently ': 'هل أنت متأكد أنك تريد  ',
    'delete your Hands account? This action ':
        'حذف حسابك في Hands؟ هذا الإجراء ',
    'cannot be undone.': 'لا يمكن التراجع عنه.',
    'This action cannot be undone.': 'لا يمكن التراجع عن هذا الإجراء.',
    'No posts yet. Be the first who post!':
        'لا توجد منشورات بعد. كن أول من ينشر!',
    'No posts yet': 'لا توجد منشورات بعد',
    'No posts found for ': 'لم يتم العثور على منشورات لـ ',
    'Send message': 'إرسال رسالة',
    'Share profile': 'مشاركة الملف الشخصي',
    'Block account': 'حظر الحساب',
    'Report account': 'الإبلاغ عن الحساب',
    'Why are you reporting this post?': 'لماذا تريد الإبلاغ عن هذا المنشور؟',
    'Inappropriate content': 'محتوى غير لائق',
    'Scam or fraud': 'احتيال أو نصب',
    'Spam or fake account': 'رسائل مزعجة أو حساب مزيف',
    'Harassment or bullying': 'تحرش أو تنمر',
    'Pretending to be someone else': 'انتحال شخصية شخص آخر',
    'Submit report': 'إرسال البلاغ',
    'Additional details (optional)': 'تفاصيل إضافية (اختياري)',
    'Start the conversation!': 'ابدأ المحادثة!',
    'Send the first message to your group.': 'أرسل أول رسالة إلى مجموعتك.',
    'Message your group...': 'أرسل رسالة إلى مجموعتك...',
    'Tell students a little about yourself !': 'عرّف الطلاب بنفسك قليلًا!',
    'Please select your Wilaya and residence.':
        'يرجى اختيار الولاية والإقامة الجامعية الخاصة بك.',
    'Bio cannot exceed 300 characters.':
        'يجب ألا يتجاوز النبذة التعريفية 300 حرف.',
    'Get help with an account or a problem':
        'احصل على المساعدة بشأن حسابك أو أي مشكلة تواجهك',
  },
};

String text(BuildContext context, String key) {
  final locale = context.watch<LanguageManager>().locale.languageCode;
  return languages[locale]?[key] ?? languages['en']?[key] ?? key;
}

String textRead(BuildContext context, String key) {
  final locale = context.read<LanguageManager>().locale.languageCode;
  return languages[locale]?[key] ?? languages['en']?[key] ?? key;
}
