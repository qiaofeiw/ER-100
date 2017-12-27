/******************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd
** All rights reserved.
** For any questions to The Qt Company, please use contact form at http://qt.io
**
** This file is part of the Qt Virtual Keyboard module.
**
** Licensees holding valid commercial license for Qt may use this file in
** accordance with the Qt License Agreement provided with the Software
** or, alternatively, in accordance with the terms contained in a written
** agreement between you and The Qt Company.
**
** If you have questions regarding the use of this file, please use
** contact form at http://qt.io
**
******************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.0

/*!
    \qmltype KeyboardRow
    \inqmlmodule QtQuick.Enterprise.VirtualKeyboard
    \ingroup qtvirtualkeyboard-qml
    \inherits RowLayout

    \brief Keyboard row for keyboard layouts.

    Specifies a row of keys in the keyboard layout.
*/

RowLayout {
    /*! Sets the key weight for all children keys.

        The default value is inherited from the parent element
        in the layout hierarchy.
    */
    property real keyWeight: parent ? parent.keyWeight : undefined
    spacing: 0
}