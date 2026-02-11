# Campus Events App

Bienvenue sur **Campus Events App** (Ynov Events), une application mobile développée avec Flutter permettant aux étudiants de consulter et de gérer les événements du campus.

##  Fonctionnalités

- **Authentification** :
  - Inscription et Connexion via Email/Mot de passe.
  - Connexion rapide via **Google Sign-In**.
- **Fil d'actualité** :
  - Section "À la une" pour les événements importants.
  - Liste complète de tous les événements disponibles.
- **Gestion des événements** :
  - Ajout de nouveaux événements avec image (galerie), titre, description et date.
  - Indicateur pour mettre un événement "À la une".
- **Favoris** :
  - Sauvegarde des événements préférés en local.
- **Profil Utilisateur** :
  - Affichage des informations de l'utilisateur (Avatar, Nom, Email).
  - Déconnexion.

## 🛠 Technologies utilisées

- **Frontend** : [Flutter](https://flutter.dev/) (Dart)
- **Backend** : [Firebase](https://firebase.google.com/)
  - **Authentication** : Gestion des utilisateurs.
  - **Cloud Firestore** : Base de données NoSQL pour stocker les événements et les utilisateurs.

##  Fonctionnement Technique

### 1. Gestion des Images (Base64)
Pour simplifier l'architecture et éviter l'utilisation de Firebase Storage car elle est une fontionnalité payante , le stockage des images a été implémenté de la manière suivante :
- **Sélection** : L'utilisateur choisit une image depuis sa galerie via le package `image_picker`.
- **Encodage** : L'image est convertie en tableau d'octets (`Uint8List`) puis encodée en une chaîne de caractères **Base64**.
- **Stockage** : Cette chaîne Base64 est enregistrée directement dans le champ `image_url` du document Firestore (collection `users` ou `events`).
- **Affichage** : Une fonction utilitaire (`displayImage` dans `utils.dart`) détecte automatiquement le format :
  - Si c'est une URL (commence par `http`) : Affiche via `NetworkImage` (ex: image Google).
  - Si c'est du Base64 : Décode et affiche via `MemoryImage`.
  - Sinon : Affiche une image par défaut (Asset).

### 2. Authentification Google
L'intégration de Google Sign-In suit un flux sécurisé en plusieurs étapes :
1.  **Native Auth** : Le package `google_sign_in` lance le flux d'authentification natif Android/iOS.
2.  **Credential** : L'application récupère les jetons d'accès (`accessToken` et `idToken`) fournis par Google.
3.  **Firebase Auth** : Ces jetons sont utilisés pour créer un `GoogleAuthCredential` et connecter l'utilisateur à Firebase.
4.  **Création de Profil** :
    - Après la connexion, l'application vérifie si c'est un nouvel utilisateur (`isNewUser`).
    - Si oui, un document est créé dans la collection `users` de Firestore avec l'UID, le nom, l'email et l'URL de la photo Google.
5.  **Prérequis** :
    - L'empreinte **SHA-1** de la clé de signature (debug) doit être ajoutée dans la console Firebase.
    - L'API **Google People API** doit être activée dans la console Google Cloud pour permettre l'accès aux informations du profil.

### 3. Structure de la Base de Données (Firestore)
- **Collection `users`** :
  - `uid` (String) : Identifiant unique Firebase Auth.
  - `name` (String) : Nom de l'utilisateur.
  - `email` (String) : Email de l'utilisateur.
  - `image_url` (String) : URL Google ou chaîne Base64.
  - `created_at` (Timestamp) : Date de création.

- **Collection `events`** :
  - `title` (String) : Titre de l'événement.
  - `description` (String) : Description détaillée.
  - `date` (Timestamp) : Date de l'événement.
  - `image_url` (String) : Image de l'événement (Base64).
  - `is_featured` (Boolean) : Si l'événement doit apparaître "À la une".

##  Description des Fichiers (`lib/pages`)

- **`inter.dart` (WelcomePage)** : Page d'introduction affichée au lancement, proposant les options de connexion ou d'inscription.
- **`signup.dart`** : Gère l'inscription des utilisateurs (Email/Mot de passe ou Google) et la création du profil dans Firestore (avec photo).
- **`connexion.dart`** : Gère l'authentification des utilisateurs existants.
- **`bottomnav.dart`** : Contient la barre de navigation (BottomNavigationBar) qui permet de naviguer entre les pages principales (Home, Réservations, Favoris, Profil).
- **`home.dart`** : Page d'accueil affichant le fil d'actualité des événements (À la une et liste complète).
- **`detail_page.dart`** : Affiche les détails complets d'un événement sélectionné et permet d'effectuer une réservation ou d'ajouter aux favoris.
- **`reservations.dart`** : Liste les réservations de l'utilisateur connecté et permet de les annuler.
- **`favories.dart`** : Affiche la liste des événements ajoutés aux favoris.
- **`profil.dart`** : Affiche les informations personnelles de l'utilisateur et permet de se déconnecter.
- **`add_event.dart`** : Page permettant de créer et d'uploader de nouveaux événements dans la base de données.

##  Installation et Configuration

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installé.
- Un émulateur Android ou un appareil physique configuré.

### Étapes


2.  **Installer les dépendances** :
    ```bash
    flutter pub get
    ```

3.  **Configuration Firebase** :
    - Créez un projet sur la [Console Firebase](https://console.firebase.google.com/).
    - Ajoutez une application Android avec le nom de package (ex: `com.example.campusEventsApp`).
    - Téléchargez le fichier `google-services.json`.
    - Placez le fichier dans `android/app/google-services.json`.
    - Dans la console Firebase :
      - Activez **Authentication** (fournisseurs Email/Password et Google).
      - Activez **Firestore Database**.

4.  **Configuration Google Sign-In** :
    - Pour que la connexion Google fonctionne, vous devez ajouter l'empreinte **SHA-1** de votre clé de signature (debug keystore) dans les paramètres de votre projet Firebase.
    - Commande pour obtenir le SHA-1 :
      - Windows : `cd android && gradlew signingReport`
      

5.  **Lancer l'application** :
    ```bash
    flutter run
    ```