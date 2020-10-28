module radarwidget;

import qui.qui;

package class RadarWidget : QWidget{
private:
	/// stores angles of scan lines (radians). This is only used to draw a line on the rader
	float[] _scanLineAngles;
	/// unit angle, i.e a value for distance is measured every unit angle (radians)
	float _unitAngle;
	/// stores distance at every unit angle (starting from 0 rad)
	float[] _distances;
}