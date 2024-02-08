package util;

class ReflectUtil
{
	@:noCompletion inline static function __getPropLoop(_get:Dynamic->String->Dynamic, object:Dynamic, fields:Array<String>):Dynamic
	{
		if (fields.length == 0) // no fields - no nothin'
			return null;

		if (fields.length == 1) // one field? - come on :/
			return _get(object, fields[0]);

		var prop:Dynamic = object;
		for (field in fields) // looping through all given fields
			prop = _get(prop, field);

		return prop;
	}

	@:noCompletion inline static function __setPropLoop(_get:Dynamic->String->Dynamic, _set:Dynamic->String->Dynamic->Void, object:Dynamic,
		fields:Array<String>, value:Dynamic)
	{
		if (fields.length == 0) // no fields - no nothin'
			return;

		if (fields.length == 1) // one field? - come on :/
		{
			_set(object, fields[0], value);
			return;
		}

		final copy = fields.copy();	// copy fields
		final target = copy.pop();	// remove and return last field since it's the one that needs to be set
		if (copy.length == 1)		// no need in for loop if only one field remains
		{
			_set(_get(object, copy[0]), target, value);
			return;
		}

		var prop:Dynamic = object;
		for (field in copy) // looping through all given fields
			prop = _get(prop, field);

		_set(prop, target, value);
	}

	public static function getPropertyLoop(object:Dynamic, fields:Array<String>):Dynamic
	{
		return __getPropLoop(Reflect.getProperty, object, fields);
	}

	public static function getFieldLoop(object:Dynamic, fields:Array<String>)
	{
		return __getPropLoop(Reflect.field, object, fields);
	}

	public static function setPropertyLoop(object:Dynamic, fields:Array<String>, value:Dynamic)
	{
		__setPropLoop(Reflect.getProperty, Reflect.setProperty, object, fields, value);
	}

	public static function setFieldLoop(object:Dynamic, fields:Array<String>, value:Dynamic)
	{
		__setPropLoop(Reflect.field, Reflect.setField, object, fields, value);
	}
}