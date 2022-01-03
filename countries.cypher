PROFILE
EXPLAIN

------------------------------------------------
MATCH (n) DETACH DELETE n
MATCH (n) RETURN n

*yontem 0;
CREATE INDEX ON :Country(countryID)

CREATE (:Country {name:"Türkiye"})
(:Country {name:"Bulgaristan"}),
(:Country {name:"Yunanistan"})

MATCH (c:Country) RETURN c
-----------------------------------------------

MATCH (turkiye:Country {name:"Türkiye"})
MATCH (y:Country {name:"Yunanistan"})
CREATE (turkiye)-[:Komsu]->(y)

MATCH (turkiye:Country {name:"Türkiye"})
MATCH (b:Country {name:"Bulgaristan"})
CREATE (turkiye)-[:Komsu]->(b)

*yontem 1;
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/vezir/sampledata/main/countries.csv' AS row
FIELDTERMINATOR ','
with row
MERGE (c:Country {name:row.ulke})
RETURN c

MATCH (c:Country)
WHERE NOT c.name='Türkiye' 
MATCH (t:Country)
WHERE t.name='Türkiye' 
MERGE (t)-[k:Komsu]->(c)
RETURN t, k, c

CREATE (:Country {name:"Arnavutluk"})
CREATE (:Country {name:"Kuzey Makedonya"})
CREATE (:Country {name:"Romanya"})
CREATE (:Country {name:"Sýrbistan"})

MATCH (c:Country)
WHERE c.name='Yunanistan' 
MATCH (t:Country)
WHERE (t.name='Bulgaristan' OR  t.name='Kuzey Makedonya') and not exists((t)-[:Komsu]->(c))
MERGE (t)-[k:Komsu]->(c)
RETURN t, k, c

MATCH (c:Country)
WHERE c.name='Bulgaristan' 
MATCH (t:Country)
WHERE t.name in ['Türkiye', 'Yunanistan', 'Kuzey Makedonya', 'Sýrbistan', 'Romanya'] and not exists((t)-[:Komsu]-(c))
MERGE (t)-[k:Komsu]->(c)
RETURN t, k, c

MATCH (c:Country)-[k:Komsu]-(c2:Country) RETURN c, k, c2

** Komsularin komsulari
MATCH (c:Country)-[:Komsu*2..2]->(c2:Country)
Return c, c2




--------------------------------------------------------------------------------------
--- https://medium.com/neo4j/learn-geography-using-neo4j-6bc1314f57ba

WITH "https://gist.githubusercontent.com/jimmycrequer/7aa867900d0cf0b9588d4354f09cb286/raw/countries.json" AS url
CALL apoc.load.json(url) YIELD value AS v
MERGE (c:Country {name: v.name})
SET c.population = v.population, c.area = v.area
CREATE (capital:City {name: v.capital})
CREATE (c)<-[:IS_CAPITAL_OF]-(capital)
FOREACH (n IN v.neighbors |
  MERGE (neighbor:Country {name: n})
  MERGE (c)-[:IS_NEIGHBOR_OF]-(neighbor)
)
RETURN *

--the top 10 biggest countries in Europe
MATCH (c:Country)
RETURN c.name AS country, apoc.number.format(c.area) AS area
ORDER BY c.area DESC
LIMIT 10

-- Let’s now have a look at the relationships between countries.
MATCH (c:Country)-[:IS_NEIGHBOR_OF]-(c2:Country)
WITH c, collect(c2.name) AS neighbors
RETURN c.name, neighbors
ORDER BY size(neighbors) DESC

-- Map of europe
MATCH (c1:Country)-[nb:IS_NEIGHBOR_OF]-(c2:Country)
RETURN c1,nb,c2

-- make use of Neo4j’s “shortestPath()” function to know how many countries need to be crossed to reach 2 specified countries
MATCH (france:Country {name: "France"}), 
      (greece:Country {name: "Greece"}),
      p = shortestPath((france)-[*]-(greece))
RETURN p

MATCH (italy:Country {name: "Italy"}), 
      (turkey:Country {name: "Turkey"}),
      p = shortestPath((italy)-[:IS_NEIGHBOR_OF*1..7]-(turkey))
RETURN p


