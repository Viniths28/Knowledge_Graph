CREATE (a:Person {name:'Alice', email: 'alice@example.com'});
CREATE (b:Person {name:'Bob', email: 'bob@example.com'});
CREATE (a)-[:KNOWS {since: date('2023-01-01')}]->(b);
