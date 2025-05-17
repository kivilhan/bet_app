const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

// Set emulator host
process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";

// Initialize app with dummy config
admin.initializeApp({
  projectId: "guessio-e6150" // <- use your actual local project ID if different
});

const db = admin.firestore();

const users = Array.from({ length: 5 }, (_, i) => ({
  id: uuidv4(),
  username: `user${i + 1}`,
  lastClaimDate: new Date(),
  betbucks: 1000 + i * 20000,
  totalAssets: 1000 + i * 20000,
  initialized: true
}));

const events = [
  {
    id: uuidv4(),
    title: "Who will win the match?",
    createdById: users[0].id,
    options: ["Team A", "Team B"],
    createdAt: new Date(),
    status: "takingBets"
  },
  {
    id: uuidv4(),
    title: "What will be the weather?",
    createdById: users[1].id,
    options: ["Sunny", "Rainy", "Snowy"],
    createdAt: new Date(),
    status: "takingBets"
  }
];

const bets = [
  { userId: users[0].id, eventId: events[0].id, option: "Team A", amount: 200 },
  { userId: users[1].id, eventId: events[0].id, option: "Team B", amount: 150 },
  { userId: users[2].id, eventId: events[0].id, option: "Team A", amount: 3000 },
  { userId: users[3].id, eventId: events[0].id, option: "Team A", amount: 10000 },
  { userId: users[4].id, eventId: events[1].id, option: "Sunny", amount: 25000 },
  { userId: users[0].id, eventId: events[1].id, option: "Rainy", amount: 10000 },
  { userId: users[1].id, eventId: events[1].id, option: "Sunny", amount: 300 },
  { userId: users[2].id, eventId: events[1].id, option: "Rainy", amount: 2000 },
  { userId: users[3].id, eventId: events[1].id, option: "Snowy", amount: 1050 },
  { userId: users[4].id, eventId: events[1].id, option: "Sunny", amount: 20000 }
].map(bet => ({
  id: uuidv4(),
  ...bet,
  placedAt: new Date()
}));

async function seed() {
  // Clear existing docs (optional)
  await Promise.all([
    db.collection("users").get().then(snapshot =>
      Promise.all(snapshot.docs.map(doc => doc.ref.delete()))
    ),
    db.collection("events").get().then(snapshot =>
      Promise.all(snapshot.docs.map(doc => doc.ref.delete()))
    ),
    db.collection("bets").get().then(snapshot =>
      Promise.all(snapshot.docs.map(doc => doc.ref.delete()))
    )
  ]);

  // Seed users
  await Promise.all(
    users.map(user => db.collection("users").doc(user.id).set(user))
  );

  // Seed events
  await Promise.all(
    events.map(event => db.collection("events").doc(event.id).set(event))
  );

  // Seed bets
  await Promise.all(
    bets.map(bet => db.collection("bets").doc(bet.id).set(bet))
  );

  console.log("✅ Seeded Firestore emulator successfully.");
}

seed().catch(error => {
  console.error("❌ Seeding failed:", error);
});
