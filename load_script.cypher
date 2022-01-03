MATCH (n) DETACH DELETE n
MATCH (n) RETURN n

CALL dbms.listConfig('dbms.transaction.timeout')
CALL dbms.setConfigValue('dbms.transaction.timeout', '3m')

:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/vezir/sampledata/main/894371739_T_MASTER_CORD.csv" as line
FIELDTERMINATOR ';'
with line where line.ID is not null
MERGE (n:Airport {airport_id:toInteger(line.ID)})
   ON CREATE SET n.airport_name = line.DISPLAY_AIRPORT_NAME, 
                 n.country_code = line.AIRPORT_COUNTRY_CODE_ISO, 
				 n.state_name   = line.AIRPORT_STATE_NAME,
				 n.lat = line.LATITUDE,
				 n.long = line.LONGITUDE,
				 n.status = line.AIRPORT_STATUS
				
Added 6545 labels, created 6545 nodes, set 35907 properties, completed after 34211 ms.

MATCH (a:Airport) RETURN a LIMIT 10

CREATE CONSTRAINT ON (a:Airport) ASSERT a.airport_id IS UNIQUE;
#CREATE INDEX ON (a:Airport) a.airport_id IS UNIQUE;



LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/vezir/sampledata/main/462172340_T_ONTIME_REPORTING_SAMPLE2.csv" as line
FIELDTERMINATOR ';'
with line where line.AIR_TIME is not null and line.FL_DATE='01.01.2020'
RETURN line
LIMIT 20





Neo.ClientError.Transaction.TransactionTimedOut
The transaction has been terminated. Retry your operation in a new transaction, and you should see a successful result. The transaction has not completed within the specified timeout (dbms.transaction.timeout). You may want to retry with a longer timeout. 

:auto USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/vezir/sampledata/main/462172340_T_ONTIME_REPORTING_SAMPLE3.csv" as line
FIELDTERMINATOR ';'
with line where line.AIR_TIME is not null and line.FL_DATE="01.01.2020"
MERGE (s:Airport {airport_id : toInteger(line.Source)})
MERGE (t:Airport {airport_id : toInteger(line.Target)})
MERGE (s)-[:`FLIGHT` {distance:line.DISTANCE,air_time:line.AIR_TIME, fl_date:line.FL_DATE}]->(t)

Set 43077 properties, created 14359 relationships, completed after 4212 ms.

:auto USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/vezir/sampledata/main/462172340_T_ONTIME_REPORTING_SAMPLE3.csv" as line
FIELDTERMINATOR ';'
with line where line.AIR_TIME is not null and line.FL_DATE="01.01.2020"
MATCH (s:Airport {airport_id : toInteger(line.Source)})
MATCH (t:Airport {airport_id : toInteger(line.Target)})
CREATE (s)-[:`FLIGHT` {distance:line.DISTANCE,air_time:line.AIR_TIME, fl_date:line.FL_DATE}]->(t)

Set 53907 properties, created 17969 relationships, completed after 9914 ms.

LOAD CSV FROM 'https://raw.githubusercontent.com/vezir/sampledata/main/894371739_T_MASTER_CORD.csv' AS row
RETURN row
LIMIT 20
	
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/vezir/sampledata/main/462172340_T_ONTIME_REPORTING_SAMPLE.csv" as line
FIELDTERMINATOR ';'
with line where line.AIR_TIME is not null and line.AIR_TIME='01.01.2020'
RETURN line
LIMIT 20
	
MERGE (n)-[to:TO]->(n)
  ON CREATE SET to.air_time = line.AIR_TIME, 
                to.distance = line.DISTANCE

CREATE 
  (`0` :Airport {name:'string'}) ,
  (`1` :Airport {name:'string'}) ,
  (`0`)-[:`FLIGHT` {distance:'integer',air_time:'integer'}]->(`1`)
  
  
  
  QUERIES
* Los Angeles International havaalanina dogrudan baglantili ucus olan havalanlari hangileri?
MATCH (d:Airport)<-[:FLIGHT]-(s:Airport) where d.airport_name='Los Angeles International' Return Distinct s.airport_name order by s.airport_name

* sonucu bir listeye koyma
MATCH (s:Airport)-[:FLIGHT]-(d:Airport) where d.airport_name='Los Angeles International' Return COLLECT( Distinct s.airport_name)

MATCH (s:Airport)-[:FLIGHT]-(d:Airport) 
where d.airport_name='Los Angeles International' 
WITH COLLECT( Distinct s) as airports
CALL apoc.algo.pageRankWithConfig(airports, {iterations:20, types:'FLIGHT'})
YIELD node, score
RETURN node.name, score
ORDER BY score DESC


------------------------ DS ----------------------------------------------------------------------------------------
:play https://guides.neo4j.com/sandbox/graph-data-science/index.html

Enable multi statement queries
:config "enableMultiStatementMode":true

MATCH (c:Person)-[:INTERACTS]->()
WITH c, count(*) AS num
RETURN min(num) AS min, max(num) AS max, avg(num) AS avg_interactions, stdev(num) AS stdev

* required memory estimation
CALL gds.graph.create.estimate('Person', 'INTERACTS') YIELD nodeCount, relationshipCount, requiredMemory

*Create the graph !
CALL gds.graph.create('got-interactions', 'Person', 'INTERACTS')

* Estimate memory usage: algorithms: To estimate the memory needed to execute an algorithm on your got-interactions graph, for example, Page Rank
CALL gds.pageRank.stream.estimate('got-interactions') YIELD requiredMemory

CALL gds.pageRank.stream.estimate({
  nodeProjection: 'Person',
  relationshipProjection: 'INTERACTS'
}) YIELD mapView
UNWIND [ x IN mapView.components | [x.name, x.memoryUsage] ] AS component
RETURN component[0] AS name, component[1] AS size

* kullanmadiklarimizi silelim
CALL gds.graph.drop('got-interactions');

* Graph catalog: standard creation and Cypher projection
* The GDS library supports two approaches for loading projected graphs - standard creation (gds.graph.create()) and Cypher projection (gds.graph.create.cypher()).

CALL gds.graph.create.cypher(
  'got-interactions-cypher',
  'MATCH (n:Person) RETURN id(n) AS id',
  'MATCH (s:Person)-[i:INTERACTS]->(t:Person) RETURN id(s) AS source, id(t) AS target, i.weight AS weight'
)

* same house

CALL gds.graph.create.cypher(
  'same-house-graph',
  'MATCH (n:Person) RETURN id(n) AS id',
  'MATCH (p1:Person)-[:BELONGS_TO]-(:House)-[:BELONGS_TO]-(p2:Person) RETURN id(p1) AS source, id(p2) AS target'
)

* list graphs

CALL gds.graph.list()

* graph existance
CALL gds.graph.exists('got-interactions')

* temizlik
CALL gds.graph.drop('got-interactions-cypher');

**** With Neo4j, you can run algorithms on explicitly and implicitly created graphs. ***

Page Rank
Label Propagation
Weakly Connected Components (WCC)
Louvain
Node Similarity
Triangle Count
Local Clustering Coefficient

* explicit syntax
CALL gds.<algo-name>.<mode>(
  graphName: String,
  configuration: Map
)

<algo-name> is the algorithm name.
<mode> is the algorithm execution mode. The supported modes are:
write: writes results to the Neo4j database and returns a summary of the results.
stats: same as write but does not write to the Neo4j database.
stream: streams results back to the user.
The graphName parameter value is the name of the graph from the graph catalog.
The configuration parameter value is the algorithm-specific configuration.

* implicit syntax
*  The implicit variant does not access the graph catalog. If you want to run an algorithm on such a graph, you configure the graph creation within the algorithm configuration map.
CALL gds.<algo-name>.<mode>(
  configuration: Map
)

** Page Rank (to find the most influential nodes in a graph.)
- stream mode
CALL gds.pageRank.stream('got-interactions') YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC LIMIT 10

- write mode
CALL gds.pageRank.write('got-interactions', {writeProperty: 'pageRank'})

* implicit run
CALL gds.pageRank.write({
  nodeProjection: 'Person',
  relationshipProjection: {
    INTERACTS_1: {
      orientation: 'UNDIRECTED'
    }
  },
  writeProperty: 'pageRank-1'
})

calismadan sonra graf memiroyden silinir !

** Label Propagation
Label Propagation (LPA) is a fast algorithm for finding communities in a graph. It propagates labels throughout the graph and forms communities of nodes based on their influence.

CALL gds.graph.create(
  'got-interactions-weighted',
  'Person',
  {
    INTERACTS: {
      orientation: 'UNDIRECTED',
      properties: 'weight'
    }
  }
)

CALL gds.labelPropagation.stream(
  'got-interactions-weighted',
  {
    relationshipWeightProperty: 'weight',
    maxIterations: 2
  }
) YIELD nodeId, communityId
RETURN communityId, count(nodeId) AS size
ORDER BY size DESC
LIMIT 5

** Weakly Connected Components
finds sets of connected nodes in an undirected graph, where each node is reachable from any other node in the same set

CALL gds.graph.create('got-interactions', 'Person', {
  INTERACTS: {
    orientation: 'UNDIRECTED'
  }
})

CALL gds.wcc.stream('got-interactions')
YIELD nodeId, componentId
RETURN componentId AS component, count(nodeId) AS size
ORDER BY size DESC

* same culture
CALL gds.graph.create.cypher(
  'got-culture-interactions-cypher',
  'MATCH (n:Person) RETURN id(n) AS id',
  'MATCH (p1:Person)-[:MEMBER_OF_CULTURE]->(c:Culture)<-[:MEMBER_OF_CULTURE]-(p2:Person) RETURN id(p1) AS source, id(p2) AS target'
)

CALL gds.wcc.stream('got-culture-interactions-cypher')
YIELD nodeId, componentId
RETURN componentId AS component, count(nodeId) AS size ORDER BY size DESC

** 41 Louvain hierarchical clustering algorithm
is a community detection algorithm designed to identify clusters of nodes in a graph

** 46 Node Similarity The algorithm uses the so-called Jaccard Similarity Score
compares pairs of nodes in a graph based on their connections to other nodes. 
Two nodes are considered similar if they share many of the same neighbors.

CALL gds.graph.create('got-character-related-entities', ['Person', 'Book', 'House', 'Culture'], '*')

CALL gds.nodeSimilarity.stream(
  'got-character-related-entities',
  {
    degreeCutoff: 20
  }
)
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).name AS character1, gds.util.asNode(node2).name AS character2, similarity
ORDER BY similarity DESC
LIMIT 10

CALL gds.nodeSimilarity.stream(
  'got-character-related-entities',
  {
    degreeCutoff: 20,
    similarityCutoff: 0.45
  }
)
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).name AS character1, gds.util.asNode(node2).name AS character2, similarity
ORDER BY similarity DESC

CALL gds.nodeSimilarity.write(
  'got-character-related-entities',
  {
    degreeCutoff: 20,
    topN: 10,
    topK: 1,
    writeRelationshipType: 'SIMILARITY',
    writeProperty: 'character_similarity'
  }
)

CALL gds.graph.drop('got-character-related-entities');

** 55 Triangle Count
a set of three nodes all connected to each other. For only Undirected graphs

MATCH (n:Person)-[r:INTERACTS_1]->(m:Person)
WHERE n.name IN ["Robb Stark", "Tyrion Lannister"]
RETURN n, m, r

** 67 Betweenness Centrality
the amount of influence a node has over the flow of information in a graph. It is often used to find nodes that serve as a bridge from one part of a graph to another.

CALL gds.betweenness.stream('got-interactions') YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC LIMIT 10

CALL gds.betweenness.stream('got-interactions', {samplingSize: 1083}) YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC LIMIT 10


---------------------------------------------
-- HOP
MATCH (bob:Person { name : "Guyard Morrigen" })
WITH bob
MATCH p=(bob)-[:INTERACTS*1..2]-(rob:Person { name : "Robb Stark" })
RETURN p

-- Butun baglantilar 2 hop
MATCH (bob:Person { name : "Guyard Morrigen" })
WITH bob
MATCH p=(bob)-[*1..2]-(rob:Person { name : "Robb Stark" })
RETURN p

-- Bazý baglantilar (INTERACTS veya APPEARED_IN) 2 hop

MATCH (bob:Person { name : "Guyard Morrigen" })
WITH bob
MATCH p=(bob)-[:INTERACTS|APPEARED_IN*1..2]-(rob:Person { name : "Robb Stark" })
RETURN p

Denormalized:
CREATE (p1:Person { name: "David", interest: ["Guitar"] })
CREATE (p2:Person { name: "Sarah", interest: ["Guitar"] })
Normalized:
CREATE (s:Interest { name: "Guitar" })
CREATE (p1:Person { name: "David" })
CREATE (p1)-[:HAS]->(s)
CREATE (p2:Person { name: "Sarah" })
CREATE (p2)-[:HAS]->(s)


