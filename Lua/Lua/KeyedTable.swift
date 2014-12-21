import Foundation

public final class KeyedTable<K: Value, T: Value where K: Hashable>: Value { // is there a less dumb way to write the generic signature here?
    
    public var elements = [K:T]()
    
    public func pushValue(L: VM) {
        L.pushTable(keyCapacity: elements.count)
        let tablePosition = Int(lua_absindex(L.L, -1)) // overkill? dunno.
        for (key, value) in elements {
            key.pushValue(L)
            value.pushValue(L)
            L.setTable(tablePosition)
        }
    }
    
    public class func fromLua(L: VM, var at position: Int) -> KeyedTable<K, T>? {
        position = L.absolutePosition(position) // pretty sure this is necessary
        
        var dict = KeyedTable<K, T>()
        
        L.pushNil()
        while lua_next(L.L, Int32(position)) != 0 {
            let key = K.fromLua(L, at: -2)
            let val = T.fromLua(L, at: -1)
            L.pop(1)
            
            // non-int key or non-T value
            if key == nil || val == nil { return nil }
            
            dict.elements[key!] = val!
        }
        
        return dict
    }
    
    public subscript(key: K) -> T? { return elements[key] }
    
    public init() {}
    
    public init(_ values: [K:T]) {
        elements = values
    }
    
    public class func typeName() -> String { return "<Dictionary of \(K.typeName()) : \(T.typeName())>" }
    public class func kind() -> Kind { return .Table }
    public class func arg() -> TypeChecker { return (KeyedTable<K,T>.typeName, KeyedTable<K,T>.isValid) }
    public class func isValid(L: VM, at position: Int) -> Bool {
        return L.kind(position) == kind() && KeyedTable<K,T>.fromLua(L, at: position) != nil
    }
    
}
