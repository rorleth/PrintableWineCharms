// parameters for the charm
// Name to go on the charm
name = "Maria";
// font size
fontSize = 8;
// font name
font = "Broadway";
// how high the font is elevated over the baseplate
fontLayerDepth = 1;
// how thick to make the plate that the name is printed on
bottomPlateThickness = 2;
// margin between font and outer edge of plate
textMargin = 2;

// want a raised border ? That's how you get a border
borderThickness = 1;

// height of said border - modify if you want a border that stands out higher than the font
borderHeight = bottomPlateThickness + fontLayerDepth; 

// parameters for the wine glass they're supposed to fit on
// radius of the attachment ring
innerRadius = 6;
// how thick to make the ring
ringThickness = 2;
// how big is the opening - that needs to be just a little smaller than your glass' stem
stemThickness = 8;

// normalize nameplate to that size in order to get a fixed height regardless of characters used in font
bottomPlateHeight = fontSize * 1.5 + 2 * textMargin; 

// used a couple of times to write the name, hence pulling into own module
module write_name(output) {
    text(
        text = output, 
        size = fontSize, 
        font = font, 
        valign = "center", 
        halign = "center",
        $fn = 50
    );    
}

// figure out the bounding rectangle of the text, which depends on font, font size and margin
// taken approach/idea/code from https://mastering-openscad.eu/buch/example_06/ 
// - basically project the text on to x axis to get width (and take hull to not get a 
// collection of rectangles) then project on to y axis to get height
module text_area(output) {

    estimated_length = len(output) * fontSize * 2;
    
    // set the resulting height to a constant, else it's going to depend
    // on whether really tall characters are being used or not (Italic capital G for instance)
    resize([0,bottomPlateHeight,0], auto =[false, true, false])
    offset( delta = textMargin )
    projection()
    intersection(){
        translate( [0,0,-1] )
        rotate([-90,0,0])
        translate([0,0,-(3 * fontSize) / 2])
        linear_extrude( height = 3 * fontSize )
        hull()
        projection()
        rotate([90,0,0])
        linear_extrude( height = 1)
        write_name(output);


        rotate( [0, -90, 0] )
        translate( [0, 0, -estimated_length/2] )
        linear_extrude( height = estimated_length )
        hull()
        projection()    
        rotate( [0, 90, 0] )
        linear_extrude( height = 1 )
        write_name(output);
    }
}

// plate to write the name on
linear_extrude( height = bottomPlateThickness )
    text_area(name);

if (borderThickness > 0)
{
    linear_extrude( height = borderHeight )
        difference()
        {
            offset (delta = borderThickness)
                text_area(name);
            text_area(name);
        }
}

// write the name
translate([0, 0,bottomPlateThickness]) 
    linear_extrude(height = fontLayerDepth)
        write_name(name);


// figure out the angle for the cylinder that cuts the opening into the ring
cutCylRad = (innerRadius+ringThickness) * tan(asin(stemThickness/(2*innerRadius)));

// add the glass attachment ring
translate([0, bottomPlateHeight / 2 + innerRadius + borderThickness, 0])
difference()
{
    // the ring
	difference()
	{
		cylinder(r=innerRadius+ringThickness, h=bottomPlateThickness);
		cylinder(r=innerRadius, h=bottomPlateThickness);
	}
    // the cut
	translate([0, innerRadius+ringThickness, ringThickness/2]) 
        rotate([90,0,0]) 
            cylinder(innerRadius+ringThickness, cutCylRad, 0); 
}
