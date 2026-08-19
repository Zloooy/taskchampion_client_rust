## 0.1.0

- Initial release
- TaskChampion client with Rust FFI bindings
- Task management (create, read, update, delete)
- Synchronization with TaskChampion sync server
- Secure authentication with encryption
- Support for Android (arm64-v8a, armeabi-v7a)

## 0.1.1

- Removed virtual tags from task instances

## 0.2.0

- Added getPropertyValues and getTags methods
- Splitted rust code

## 0.3.0

- Added `getStoredPropertyValues<T>` for typed property value queries (String, DateTime, TaskStatus, TaskPriority)
- Added `getAllPropertyValues<T>` to retrieve all possible enum values for a type
- Moved property value parsing to Rust side for type safety
- All parsing now happens in Rust; Dart generic types are mapped to Rust `PropertyReturnType`

## 0.4.0

- Added optional service injection to `TaskChampionClient` constructors (`ITaskService?`, `ISyncService?`, `IAuthService?`, `ITaskPropertyService?`, `ITaskTagService?`) for testing with mocks or custom decorators
- Added optional `eventManager` parameter to `TaskChampionClient` constructors for injecting custom event managers
- Task change events are now emitted automatically after `createTask`, `updateTask`, and `deleteTask` operations
- Sync events are now emitted via `syncEvents` stream on every sync completion (success or failure)
- Fixed `TaskPriority` enum values: now correctly uses `"H"`, `"M"`, `"L"` instead of `"high"`, `"medium"`, `"low"`
- Fixed `getStoredPropertyValues<T>` for `TaskPriority`: returns correct enum values matching stored data
- Fixed `importTasks`: per-row import errors are now properly reported instead of silently returning partial counts

## 0.4.1

- Bumped Flutter version to 3.47.0
- Bumped taskchampion version to 3.1.0

## 0.5.0

- Migrated `FilterExpression` to freezed code generation (sealed union class with typed factory constructors per filter variant, JSON union key `type` with PascalCase values)
- Added many new filter variants (`not`, xor group, tag/virtual tag, notEquals, notContains, startsWith, endsWith, word, noWord, regex, none/any, dateBefore/dateAfter/dateBy, lessThan/lessThanOrEqual/greaterThan/greaterThanOrEqual)
- `TaskPropertyRef` is now a sealed Equatable hierarchy (String/DateTime/Int/Double) with value-based equality; removed generics
- Added convenience constructors `TaskFilter.matchAll`, `.hasTag()`, `.excludeTag()`, `.virtualTag()`
- Extended property references with project, scheduled, until, id, urgency

## 0.5.1

- Migrated `TaskFilter` to freezed together with serialization fix