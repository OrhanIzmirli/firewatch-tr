import { after, before, beforeEach, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, serverTimestamp, setDoc } from 'firebase/firestore';

const progress = () => ({ days: { '2026-11-08': true }, lessons: ['see_fire'], shares: 1, observations: 0, longestStreak: 3, updatedAt: serverTimestamp() });

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-firewatch',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8087 },
  });
});
after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();
const seed = () => env.withSecurityRulesDisabled((c) => setDoc(doc(c.firestore(), 'users/alice'), { days: {}, lessons: [], shares: 0, observations: 0, longestStreak: 0 }));

test('a person can write, read and delete their own document', async () => {
  const db = as('alice');
  await assertSucceeds(setDoc(doc(db, 'users/alice'), progress()));
  await assertSucceeds(getDoc(doc(db, 'users/alice')));
  await assertSucceeds(deleteDoc(doc(db, 'users/alice')));
});

test('nobody else can read, write or delete it', async () => {
  await seed();
  const db = as('bob');
  await assertFails(getDoc(doc(db, 'users/alice')));
  await assertFails(setDoc(doc(db, 'users/alice'), progress()));
  await assertFails(deleteDoc(doc(db, 'users/alice')));
});

test('signed-out clients get nothing', async () => {
  await seed();
  await assertFails(getDoc(doc(anon(), 'users/alice')));
  await assertFails(setDoc(doc(anon(), 'users/alice'), progress()));
});

test('the collection cannot be listed', async () => {
  await seed();
  await assertFails(getDocs(collection(as('alice'), 'users')));
});

for (const field of ['location', 'latitude', 'places', 'plate', 'email']) {
  test(`${field} cannot be stored`, async () => {
    await assertFails(setDoc(doc(as('alice'), 'users/alice'), { ...progress(), [field]: 'x' }));
  });
}

test('field types are enforced', async () => {
  await assertFails(setDoc(doc(as('alice'), 'users/alice'), { ...progress(), shares: 'many' }));
  await assertFails(setDoc(doc(as('alice'), 'users/alice'), { ...progress(), days: 'x' }));
});

test('every other collection is closed', async () => {
  await assertFails(setDoc(doc(as('alice'), 'other/doc'), { a: 1 }));
  await assertFails(getDoc(doc(as('alice'), 'other/doc')));
});
