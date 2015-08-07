/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: appWindow
    property string periodShown: options.paidPeriod
    property real paidTotal: 0
    property real toPayTotal: 0

    property string variableEng: "Variable"
    property string fixedEng: "Fixed"
    property string oneTimeEng: "One Time"
    property string variable: qsTr("Variable")
    property string fixed: qsTr("Fixed")
    property string oneTime: qsTr("One Time")

    property string todayEng: "Today"
    property string last3DaysEng: "Last 3 Days"
    property string last7DaysEng: "Last 7 Days"
    property string last15DaysEng: "Last 15 Days"
    property string last30DaysEng: "Last 30 Days"
    property string thisMonthEng: "This Month"
    property string thisYearEng: "This Year"
    property string eternityEng: "Eternity"
    property string today: qsTr("Today")
    property string last3Days: qsTr("Last 3 Days")
    property string last7Days: qsTr("Last 7 Days")
    property string last15Days: qsTr("Last 15 Days")
    property string last30Days: qsTr("Last 30 Days")
    property string thisMonth: qsTr("This Month")
    property string thisYear: qsTr("This Year")
    property string eternity: qsTr("Eternity")

    property string months: qsTr("months")
    property string days: qsTr("days")

    property Item paidPage

    initialPage: Component {
        Paid {
            id: paidPage
            Component.onCompleted: appWindow.paidPage = paidPage
        }
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Component.onCompleted:
    {
        switch(options.paidPeriodIndex)
        {
        case 0:
            options.paidPeriod = today
            break;
        case 1:
            options.paidPeriod = last3Days
            break;
        case 2:
            options.paidPeriod = last7Days
            break;
        case 3:
            options.paidPeriod = last15Days
            break;
        case 4:
            options.paidPeriod = last30Days
            break;
        case 5:
            options.paidPeriod = thisMonth
            break;
        case 6:
            options.paidPeriod = thisYear
            break;
        case 7:
            options.paidPeriod = eternity
            break;
        }
    }
}


