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