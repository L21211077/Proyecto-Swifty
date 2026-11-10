<?php

require_once __DIR__ . '/../config/mongodb.php';

/**
 * Stores a snapshot of the MySQL users table as one MongoDB document.
 *
 * Password hashes are intentionally excluded from the exported snapshot.
 */
function exportUsersSnapshotToMongoDB(PDO $mysqlConnection): string
{
    $statement = $mysqlConnection->query(
        'SELECT id, username, first_name, last_name, phone, email, created_at
         FROM users
         ORDER BY id'
    );
    $users = $statement->fetchAll(PDO::FETCH_ASSOC);

    $collectionName = getenv('MONGODB_COLLECTION') ?: 'user_snapshots';
    $collection = getMongoDatabase()->selectCollection($collectionName);

    $result = $collection->insertOne([
        'exported_at' => new MongoDB\BSON\UTCDateTime(),
        'source_table' => 'users',
        'record_count' => count($users),
        'users' => $users
    ]);

    return (string) $result->getInsertedId();
}
