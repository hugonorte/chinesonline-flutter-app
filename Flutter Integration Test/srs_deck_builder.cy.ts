// Cypress Test for SRS Deck Builder (Conceptual Web Test)
// Note: As specified by the QA guidelines, this .cy.ts file is placed in the 'Flutter Integration Test' directory.
// Since this is a Flutter project, real integration tests would typically be written in Dart inside the `integration_test/` folder.
// This Cypress test simulates checking the UI behavior for the SRS logic if deployed to Flutter Web.

describe('SRS Deck Builder Logic', () => {
  beforeEach(() => {
    // Intercept API call to mock 15 backend questions
    cy.intercept('GET', '**/api/v1/sessions/new*', { fixture: 'quiz_lote.json' }).as('getLote');
    
    // Visit the quiz page
    cy.visit('/quiz');
    cy.wait('@getLote');
  });

  it('should prioritize cards with high wrong attempts (priority > 0)', () => {
    // Inject mock local storage / Hive state for specific cards
    cy.window().then((win) => {
      // Mocking Hive State where card ID 1 has 3 wrong attempts
      win.localStorage.setItem('hive_ideogram_stats', JSON.stringify({
        '1_translation': { wrongAttempts: 3, correctAttempts: 0 },
        '2_translation': { wrongAttempts: 0, correctAttempts: 5 } // Priority -5 (Memorized)
      }));
    });

    // Reload to apply mock state
    cy.reload();
    cy.wait('@getLote');

    // Verify card ID 1 appears first (highest priority)
    cy.get('[data-test="quiz-card"]').first().should('contain', 'Ideogram 1');
    
    // Verify card ID 2 (memorized) does not appear in the first 10, unless deck < 10
    cy.get('[data-test="quiz-card"]').should('not.contain', 'Ideogram 2');
  });

  it('should update correct attempts and remove from deck on next round', () => {
    // Answer correctly 5 times to hit the <= -5 threshold
    for(let i=0; i<5; i++) {
       cy.get('[data-test="option-correct"]').click();
       cy.get('[data-test="next-btn"]').click();
    }

    // On next reload, the card should be filtered out
    cy.reload();
    cy.get('[data-test="quiz-card"]').should('not.contain', 'Ideogram 1');
  });
});
