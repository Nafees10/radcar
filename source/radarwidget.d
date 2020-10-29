module radarwidget;

import utils.misc;
import qui.qui;
import std.math;
import std.conv : to;

/// block character, top filled
private const dchar BLOCKCHAR_TOP = '▀';
/// block character, bottom filled
private const dchar BLOCKCHAR_BOTTOM = '▄';
/// block character, all filled
private const dchar BLOCKCHAR_BLOCK = '█';

/// A basic radar widget that can display scan lines and 
class RadarWidget : QWidget{
private:
	/// stores angles of scan lines (unitAngle as unit). This is only used to draw a line on the rader
	uinteger[] _scanLineAngles;
	/// unit angle, i.e a value for distance is measured every unit angle (degrees)
	uinteger _unitAngle;
	/// stores distance at every unit angle (starting from 0 unitAngle)
	float[] _distances;
	/// stores the max distance to display
	float _maxDistance;
	/// the diameter of radar circle (measured as squares, so in height, this is counted as half).  
	/// This is always an odd number, calculated in resizeEvent
	uinteger _diameter;
	/// the origin of the rader circle. (measured as squares)
	uinteger _origin;
protected:
	override void update(){
		// I know this code is very un-optimized, rn, I just want it to work
		// first, draw bgColor by any cells that arent occupied by a square with length=_diameter
		if (_size.height*2 != _size.width){
			if (_size.height*2 > _size.width){
				// have to fill bottom cells
				_display.cursor = Position(0, (_diameter)/2);
				_display.fill(' ', clearColor, bgColor);
			}else{
				// have to fill right side
				foreach (y; 0 .. _size.height){
					_display.cursor = Position(_diameter-1, y);
					_display.fillLine(' ', clearColor, bgColor);
				}
			}
		}
		// now draw the circle and fill black in the square area circle resides in
		immutable uinteger radius = (_diameter+1)/2;
		immutable uinteger radiusSqr = radius*radius;
		_display.colors(clearColor, bgColor);
		foreach (actualY; 0 .. radius){
			dchar[] line;
			line.length = _diameter;
			line[] = ' ';
			foreach (y; actualY*2 .. (actualY*2) + 2){
				immutable uinteger xDist = cast(immutable uinteger)sqrt(to!float(radiusSqr - pow(radius - y, 2)));
				if (xDist == 0)
					continue;
				if (y%2 == 0){
					line[radius - xDist .. (radius-1) + xDist] = BLOCKCHAR_TOP;
					continue;
				}
				foreach (uinteger x; radius - xDist .. (radius-1) + xDist){
					if (x >= line.length)
						break;
					if (line[x] == BLOCKCHAR_TOP)
						line[x] = BLOCKCHAR_BLOCK;
					else
						line[x] = BLOCKCHAR_BOTTOM;
				}
			}
			_display.cursor = Position(0, actualY);
			_display.write(cast(dstring)line);
		}
		// now draw scan lines
		
	}
	override void resizeEvent(){
		_diameter = _size.width;
		if (_size.height*2 < _diameter)
			_diameter = _size.height*2;
		_diameter -= (_diameter+1) % 2;
		_origin = (_diameter / 2) + 1;
		requestUpdate();
	}
public:
	/// Color of scan line, obstacle, clear space, & background color 
	Color scanLineColor, obsColor, clearColor, bgColor;
	/// Constructor.  
	/// `scanLinesCount` is the number of scan lines to be displayed  
	/// `maxDiantance` is the distance of object at edge of the radar  
	/// `unitAngle` is used as the unit angle instead of the value in degrees. (i.e, 1 units = 1*unitAngle degrees).
	/// **This must be a factor of 360**  
	/// 
	/// Throws: Exception if `unitAngle` is not a factor of 360
	this(uinteger scanLinesCount = 1, float maxDistance = 10, ubyte unitAngle = 5){
		_scanLineAngles.length = scanLinesCount;
		_unitAngle = unitAngle;
		if (360 % _unitAngle > 0)
			throw new Exception("unitAngle is not a factor of 360");
		_distances.length = 360/_unitAngle;

		scanLineColor = Color.blue;
		obsColor = Color.red;
		clearColor = Color.green;
		bgColor = Color.black;
	}
	/// Set angle of a scan line.
	/// 
	/// angle is in `unitAngle`
	/// 
	/// Throws: Exception if scan line does not exist
	void setScanLineAngle(uinteger scanLine, uinteger angle){
		if (scanLine >= _scanLineAngles.length)
			throw new Exception("scan line does not exist");
		_scanLineAngles[scanLine] = angle;
		requestUpdate();
	}
	/// Sets the distance to obstacle at an angle
	/// 
	/// angle is in `unitAngle`
	void setDistance(uinteger angle, float distance){
		if (angle > _distances.length)
			angle = angle % _distances.length;
		_distances[angle] = distance;
		requestUpdate();
	}
}