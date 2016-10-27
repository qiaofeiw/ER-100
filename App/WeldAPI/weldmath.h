#ifndef WELDMATH_H
#define WELDMATH_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include <gloabldefine.h>
#include <verticalmath.h>
#include <flatmath.h>
#include <horizontalmath.h>


class WeldMath:public QObject
{
    Q_OBJECT
public:
    WeldMath();
private:
    //打底层限制条件
    FloorCondition bottomFloor;
    //第二层限制条件
    FloorCondition secondFloor;
    //填充层限制条件
    FloorCondition fillFloor;
    //盖面层限制条件
    FloorCondition topFloor;

    verticalMath vertical;

    flatMath  flat;

    horizontalMath horizontal;

    int grooveValue;

public slots:
    //设置余高
    void setReinforcement(int value);
    //溶敷系数
    void setMeltingCoefficient(int value);
    //model
    void setWeldRules(QStringList value);
    //设置坡口参数
    void setGrooveRules(QStringList value);
    //设置气体
    void setGas(int value);
    //设置脉冲
    void setPulse(int value);
    //设置焊丝种类
    void setWireType(int value);
    //设置焊丝直径
    void setWireD(int value);
    void setLimited(QStringList value);
    void setGroove(int value);
signals:
    void grooveRulesChanged(QStringList value);
    void weldRulesChanged(QStringList value);
    void gasChanged(int value);
    void pulseChanged(int value);
    void wireTypeChanged(int value);
    void wireDChanged(int value);
    void limitedChanged(QStringList value);
    void grooveChanged(int value);
};

#endif // WELDMATH_H
