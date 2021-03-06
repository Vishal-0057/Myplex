//
//  Positioner.m
//  Myplex
//
//  Created by Igor Ostriz on 9/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Positioner.h"

@implementation Positioner

static NSArray *_array;


+ (void)initialize
{
    _array =  @[@[@000.0, @263.0], @[@000.0, @263.6], @[@000.0, @264.1], @[@000.0, @264.7], @[@000.0, @265.2], @[@000.0, @265.8], @[@000.0, @266.3], @[@000.0, @266.8],
                @[@000.0, @267.4], @[@000.0, @267.9], @[@000.0, @268.4], @[@000.0, @269.0], @[@000.0, @269.5], @[@000.0, @270.0], @[@000.0, @270.6], @[@000.0, @271.1],
                @[@000.0, @271.6], @[@000.0, @272.1], @[@000.0, @272.6], @[@000.0, @273.1], @[@000.0, @273.6], @[@000.0, @274.1], @[@000.0, @274.6], @[@000.0, @275.1],
                @[@000.0, @275.6], @[@000.0, @276.1], @[@000.0, @276.6], @[@000.0, @277.1], @[@000.0, @277.6], @[@000.0, @278.1], @[@000.0, @278.5], @[@000.0, @279.0],
                @[@000.0, @279.5], @[@000.0, @280.0], @[@000.0, @280.4], @[@000.0, @280.9], @[@000.0, @281.4], @[@000.0, @281.8], @[@000.0, @282.3], @[@000.0, @282.8],
                @[@000.0, @283.2], @[@000.0, @283.7], @[@000.0, @284.1], @[@000.0, @284.6], @[@000.0, @285.0], @[@000.0, @285.5], @[@000.0, @285.9], @[@000.0, @286.4],
                @[@000.0, @286.8], @[@000.0, @287.2], @[@000.0, @287.7], @[@000.0, @288.1], @[@000.0, @288.5], @[@000.0, @289.0], @[@000.0, @289.4], @[@000.0, @289.8],
                @[@000.0, @290.2], @[@000.0, @290.7], @[@000.0, @291.1], @[@000.0, @291.5], @[@000.0, @291.9], @[@000.0, @292.3], @[@000.0, @292.7], @[@000.0, @293.1],
                @[@000.0, @293.5], @[@000.0, @293.9], @[@000.0, @294.3], @[@000.0, @294.7], @[@000.0, @295.1], @[@000.0, @295.5], @[@000.0, @295.9], @[@000.0, @296.3],
                @[@000.0, @296.7], @[@000.0, @297.1], @[@000.0, @297.5], @[@000.0, @297.9], @[@000.0, @298.3], @[@000.0, @298.6], @[@000.0, @299.0], @[@000.0, @299.4],
                @[@000.0, @299.8], @[@000.0, @300.1], @[@000.0, @300.5], @[@000.0, @300.9], @[@000.0, @301.3], @[@000.0, @301.6], @[@000.0, @302.0], @[@000.0, @302.3],
                @[@000.0, @302.7], @[@000.0, @303.1], @[@000.0, @303.4], @[@000.0, @303.8], @[@000.0, @304.1], @[@000.0, @304.5], @[@000.0, @304.8], @[@000.0, @305.2],
                @[@000.0, @305.5], @[@000.0, @305.9], @[@000.0, @306.2], @[@000.0, @306.6], @[@000.0, @306.9], @[@000.0, @307.2], @[@000.0, @307.6], @[@000.0, @307.9],
                @[@000.0, @308.3], @[@000.0, @308.6], @[@000.0, @308.9], @[@000.0, @309.2], @[@000.0, @309.6], @[@000.0, @309.9], @[@000.0, @310.2], @[@000.0, @310.6],
                @[@000.0, @310.9], @[@000.0, @311.2], @[@000.0, @311.5], @[@000.0, @311.8], @[@000.0, @312.2], @[@000.0, @312.5], @[@000.0, @312.8], @[@000.0, @313.1],
                @[@000.0, @313.4], @[@000.0, @313.7], @[@000.0, @314.0], @[@000.0, @314.3], @[@000.0, @314.6], @[@000.0, @314.9], @[@000.0, @315.2], @[@000.0, @315.5],
                @[@000.0, @315.8], @[@000.0, @316.1], @[@000.0, @316.4], @[@000.0, @316.7], @[@000.0, @317.0], @[@000.0, @317.3], @[@000.0, @317.6], @[@000.0, @317.9],
                @[@000.0, @318.2], @[@000.0, @318.5], @[@000.0, @318.8], @[@000.0, @319.1], @[@000.0, @319.4], @[@000.0, @319.6], @[@000.0, @319.9], @[@000.0, @320.2],
                @[@000.0, @320.5], @[@000.0, @320.8], @[@000.0, @321.1], @[@000.0, @321.3], @[@000.0, @321.6], @[@000.0, @321.9], @[@000.0, @322.2], @[@000.0, @322.4],
                @[@000.0, @322.7], @[@000.0, @323.0], @[@000.0, @323.2], @[@000.0, @323.5], @[@000.0, @323.8], @[@000.0, @324.1], @[@000.0, @324.3], @[@000.0, @324.6],
                @[@000.0, @324.9], @[@000.0, @325.1], @[@000.0, @325.4], @[@000.0, @325.7], @[@000.0, @325.9], @[@000.0, @326.2], @[@000.0, @326.4], @[@000.0, @326.7],
                @[@000.0, @327.0], @[@000.0, @327.2], @[@000.0, @327.5], @[@000.0, @327.7], @[@000.0, @328.0], @[@000.0, @328.2], @[@000.0, @328.5], @[@000.0, @328.8],
                @[@000.0, @329.0], @[@000.0, @329.3], @[@000.0, @329.5], @[@000.0, @329.8], @[@000.0, @330.0], @[@000.0, @330.3], @[@000.0, @330.5], @[@000.0, @330.8],
                @[@000.0, @331.0], @[@000.0, @331.3], @[@000.0, @331.5], @[@000.0, @331.8], @[@000.0, @332.0], @[@000.0, @332.3], @[@000.0, @332.5], @[@000.0, @332.8],
                @[@000.0, @333.0], @[@000.0, @333.3], @[@000.0, @333.5], @[@000.0, @333.8], @[@000.0, @334.0], @[@000.0, @334.2], @[@000.0, @334.5], @[@000.0, @334.7],
                @[@000.0, @335.0], @[@000.0, @335.2], @[@000.0, @335.5], @[@000.0, @335.7], @[@000.0, @336.0], @[@000.0, @336.2], @[@000.0, @336.5], @[@000.0, @336.7],
                @[@000.0, @336.9], @[@000.0, @337.2], @[@000.0, @337.4], @[@000.0, @337.7], @[@000.0, @337.9], @[@000.0, @338.2], @[@000.0, @338.4], @[@000.0, @338.7],
                @[@000.0, @338.9], @[@000.0, @339.2], @[@000.0, @339.4], @[@000.0, @339.7], @[@000.0, @339.9], @[@000.0, @340.2], @[@000.0, @340.4], @[@000.0, @340.7],
                @[@000.0, @340.9], @[@000.0, @341.2], @[@000.0, @341.4], @[@000.0, @341.7], @[@000.0, @341.9], @[@000.0, @342.2], @[@000.0, @342.5], @[@000.0, @342.7],
                @[@000.0, @343.0], @[@000.0, @343.2], @[@000.0, @343.5], @[@000.0, @343.8], @[@000.0, @344.0], @[@000.0, @344.3], @[@000.0, @344.6], @[@000.0, @344.8],
                @[@000.0, @345.1], @[@000.0, @345.4], @[@000.0, @345.6], @[@000.0, @345.9], @[@000.0, @346.2], @[@000.0, @346.5], @[@000.0, @346.8], @[@000.0, @347.1],
                @[@000.0, @347.3], @[@000.0, @347.6], @[@000.0, @347.9], @[@000.0, @348.2], @[@000.0, @348.5], @[@000.0, @348.8], @[@000.0, @349.1], @[@000.0, @349.4],
                @[@000.0, @349.7], @[@000.0, @350.0], @[@000.0, @350.4], @[@000.0, @350.7], @[@000.0, @351.0], @[@000.0, @351.3], @[@000.0, @351.7], @[@000.0, @352.0],
                @[@001.8, @352.3], @[@003.6, @352.7], @[@005.4, @353.0], @[@007.3, @353.4], @[@009.2, @353.8], @[@011.0, @354.1], @[@012.9, @354.5], @[@014.9, @354.9],
                @[@016.8, @355.2], @[@018.8, @355.6], @[@020.7, @356.0], @[@022.7, @356.4], @[@024.8, @356.8], @[@026.8, @357.2], @[@028.9, @357.6], @[@030.9, @358.1],
                @[@033.1, @358.5], @[@035.2, @358.9], @[@037.3, @359.4], @[@039.5, @359.8], @[@041.7, @360.3], @[@043.9, @360.7], @[@046.2, @361.2], @[@048.4, @361.7],
                @[@050.7, @362.2], @[@053.1, @362.7], @[@055.4, @363.2], @[@057.8, @363.7], @[@060.2, @364.2], @[@062.7, @364.7], @[@065.1, @365.2], @[@067.6, @365.8],
                @[@070.2, @366.3], @[@072.7, @366.9], @[@075.3, @367.5], @[@077.9, @368.0], @[@080.6, @368.6], @[@083.3, @369.2], @[@086.0, @369.8], @[@088.8, @370.5],
                @[@091.6, @371.1], @[@094.5, @371.7], @[@097.3, @372.4], @[@100.3, @373.1], @[@103.2, @373.8], @[@106.2, @374.4], @[@109.3, @375.2], @[@112.4, @375.9],
                @[@115.5, @376.6], @[@118.7, @377.4], @[@121.9, @378.1], @[@125.2, @378.9], @[@128.5, @379.7], @[@131.9, @380.5], @[@135.3, @381.3], @[@138.8, @382.1],
                @[@142.3, @383.0], @[@145.8, @383.9], @[@149.4, @384.7], @[@153.1, @385.6], @[@156.8, @386.6], @[@160.5, @387.5], @[@164.3, @388.4], @[@168.2, @389.4],
                @[@172.0, @390.4], @[@176.0, @391.4], @[@179.9, @392.4], @[@183.9, @393.4], @[@187.9, @394.5], @[@191.9, @395.5], @[@196.0, @396.6], @[@200.1, @397.6],
                @[@204.1, @398.7], @[@208.2, @399.8], @[@212.3, @400.9], @[@216.3, @402.0], @[@220.3, @403.0], @[@224.3, @404.1], @[@228.2, @405.2], @[@232.1, @406.3],
                @[@235.9, @407.3], @[@239.6, @408.3], @[@243.3, @409.4], @[@246.8, @410.4], @[@250.3, @411.3], @[@253.6, @412.3], @[@256.9, @413.2], @[@260.0, @414.1],
                @[@263.0, @415.0], @[@265.9, @415.8], @[@268.7, @416.7], @[@271.4, @417.5], @[@273.9, @418.2], @[@276.4, @419.0], @[@278.8, @419.7], @[@281.2, @420.4],
                @[@283.4, @421.1], @[@285.6, @421.8], @[@287.7, @422.4], @[@289.7, @423.1], @[@291.6, @423.7], @[@293.6, @424.3], @[@295.4, @424.9], @[@297.2, @425.5],
                @[@298.9, @426.0], @[@300.6, @426.6], @[@302.2, @427.1], @[@303.8, @427.7], @[@305.4, @428.2], @[@306.9, @428.7], @[@308.4, @429.2], @[@309.8, @429.7],
                @[@311.2, @430.2], @[@312.5, @430.7], @[@313.9, @431.2], @[@315.1, @431.7], @[@316.4, @432.1], @[@317.6, @432.6], @[@318.8, @433.1], @[@320.0, @433.5],
                @[@321.2, @433.9], @[@322.3, @434.4], @[@323.4, @434.8], @[@324.5, @435.3], @[@325.5, @435.7], @[@326.6, @436.1], @[@327.6, @436.6], @[@328.6, @437.0],
                @[@329.6, @437.4], @[@330.6, @437.8], @[@331.6, @438.2], @[@332.5, @438.7], @[@333.5, @439.1], @[@334.4, @439.5], @[@335.3, @439.9], @[@336.3, @440.4],
                @[@337.2, @440.8], @[@338.1, @441.2], @[@339.0, @441.7], @[@340.0, @442.1], @[@340.9, @442.5], @[@341.8, @443.0], @[@342.8, @443.4], @[@343.7, @443.9],
                @[@344.7, @444.4], @[@345.6, @444.9], @[@346.6, @445.3], @[@347.7, @445.8], @[@348.7, @446.4], @[@349.8, @446.9], @[@350.9, @447.4], @[@352.0, @448.0],
                @[@353.2, @449.0], @[@354.4, @450.0], @[@355.7, @451.0], @[@357.0, @452.0], @[@358.4, @453.0], @[@359.9, @454.0], @[@361.4, @455.0], @[@362.9, @456.0],
                @[@364.5, @457.0], @[@366.2, @458.0], @[@367.9, @459.0], @[@369.7, @460.0], @[@371.6, @461.0], @[@373.5, @462.0], @[@375.5, @463.0], @[@377.6, @464.0],
                @[@379.7, @465.0], @[@381.9, @466.0], @[@384.1, @467.0], @[@386.4, @468.0], @[@388.7, @469.0], @[@391.1, @470.0], @[@393.4, @471.0], @[@395.8, @472.0],
                @[@398.1, @473.0], @[@400.5, @474.0], @[@402.8, @475.0], @[@405.0, @476.0], @[@407.2, @477.0], @[@409.3, @478.0], @[@411.3, @479.0], @[@413.2, @480.0],
                @[@415.0, @481.0], @[@416.0, @482.0], @[@417.0, @483.0], @[@418.0, @484.0], @[@419.0, @485.0], @[@420.0, @486.0], @[@421.0, @487.0], @[@422.0, @488.0],
                @[@423.0, @489.0], @[@424.0, @490.0], @[@425.0, @491.0], @[@426.0, @492.0], @[@427.0, @493.0], @[@428.0, @494.0], @[@429.0, @495.0], @[@430.0, @496.0],
                @[@431.0, @497.0], @[@432.0, @498.0], @[@433.0, @499.0], @[@434.0, @500.0], @[@435.0, @501.0], @[@436.0, @502.0], @[@437.0, @503.0], @[@438.0, @504.0],
                @[@439.0, @505.0], @[@440.0, @506.0], @[@441.0, @507.0], @[@442.0, @508.0], @[@443.0, @509.0], @[@444.0, @510.0], @[@445.0, @511.0], @[@446.0, @512.0],
                @[@447.0, @513.0], @[@448.0, @514.0], @[@449.0, @515.0], @[@450.0, @516.0], @[@451.0, @517.0], @[@452.0, @518.0], @[@453.0, @519.0], @[@454.0, @520.0],
                @[@455.0, @521.0], @[@456.0, @522.0], @[@457.0, @523.0], @[@458.0, @524.0], @[@459.0, @525.0], @[@460.0, @526.0], @[@461.0, @527.0], @[@462.0, @528.0],
                @[@463.0, @529.0], @[@464.0, @530.0], @[@465.0, @531.0], @[@466.0, @532.0], @[@467.0, @533.0], @[@468.0, @534.0], @[@469.0, @535.0], @[@470.0, @536.0],
                @[@471.0, @537.0], @[@472.0, @538.0], @[@473.0, @539.0], @[@474.0, @540.0], @[@475.0, @541.0], @[@476.0, @542.0], @[@477.0, @543.0], @[@478.0, @544.0],
                @[@479.0, @545.0], @[@480.0, @546.0], @[@481.0, @547.0], @[@482.0, @548.0], @[@483.0, @549.0], @[@484.0, @550.0], @[@485.0, @551.0], @[@486.0, @552.0],
                @[@487.0, @553.0], @[@488.0, @554.0], @[@489.0, @555.0], @[@490.0, @556.0], @[@491.0, @557.0], @[@492.0, @558.0], @[@493.0, @559.0], @[@494.0, @560.0],
                @[@495.0, @561.0], @[@496.0, @562.0], @[@497.0, @563.0], @[@498.0, @564.0], @[@499.0, @565.0], @[@500.0, @566.0], @[@501.0, @567.0], @[@502.0, @568.0],
                @[@503.0, @569.0], @[@504.0, @570.0], @[@505.0, @571.0], @[@506.0, @572.0], @[@507.0, @573.0], @[@508.0, @574.0], @[@509.0, @575.0], @[@510.0, @576.0],
                @[@511.0, @577.0], @[@512.0, @578.0], @[@513.0, @579.0], @[@514.0, @580.0], @[@515.0, @581.0], @[@516.0, @582.0], @[@517.0, @583.0], @[@518.0, @584.0],
                @[@519.0, @585.0], @[@520.0, @586.0], @[@521.0, @587.0], @[@522.0, @588.0], @[@523.0, @589.0], @[@524.0, @590.0], @[@525.0, @591.0], @[@526.0, @592.0],
                @[@527.0, @593.0], @[@528.0, @594.0], @[@529.0, @595.0], @[@530.0, @596.0], @[@531.0, @597.0], @[@532.0, @598.0], @[@533.0, @599.0], @[@534.0, @600.0],
                @[@535.0, @601.0]
            ];
}

- (CGFloat)getPositionForCard:(NSUInteger)index
{
    if (index > 7) {
        return 1000000.;
    }
    return [@[@0., @263., @352., @415., @448., @481., @512., @547., @580.][index] floatValue];
}

- (CGFloat)getPreviousPositionForPosition:(CGFloat)position
{
    if (position < 0) {
        return 0;
    }
    if (position >= 448) {
        return position-33;
    }
    return [_array[(int)(position+.5)][0] floatValue];
}

- (CGFloat)getNextPositionForPosition:(CGFloat)position
{
    if (position >= 415) {
        return position+33;
    }
    if (position < 0) {
        return 0;
    }
    return [_array[(int)(position+.5)][1] floatValue];
}

@end
