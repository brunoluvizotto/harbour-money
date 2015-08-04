#include "options.h"
#include <QDate>
#include <QDebug>
#include <QProcess>

Options::Options()
{

}

void Options::setPaidPeriod(QString value)
{
    setts.setValue("paidPeriod", value);
    emit paidPeriodChanged();
}
QString Options::getPaidPeriod()
{
    return setts.value("paidPeriod", "Today").toString();
}

void Options::setPaidPeriodIndex(int value)
{
    setts.setValue("paidPeriodIndex", value);
    emit paidPeriodIndexChanged();
}
int Options::getPaidPeriodIndex()
{
    return setts.value("paidPeriodIndex", "0").toInt();
}

void Options::setTarget(float value)
{
    setts.setValue("target", value);
    emit targetChanged();
}
float Options::getTarget()
{
    return setts.value("target", "0").toFloat();
}

void Options::setDaysStat(int value)
{
    setts.setValue("daysStat", value);
    emit daysStatChanged();
}
int Options::getDaysStat()
{
    return setts.value("daysStat", "10").toInt();
}

void Options::setMonthsStat(int value)
{
    setts.setValue("monthsStat", value);
    emit monthsStatChanged();
}
int Options::getMonthsStat()
{
    return setts.value("monthsStat", "6").toInt();
}

void Options::setLastCategoryStats(int value)
{
    setts.setValue("lastCategoryStats", value);
    emit lastCategoryStatsChanged();
}
int Options::getLastCategoryStats()
{
    return setts.value("lastCategoryStats", 0).toInt();
}

void Options::setCategoryPeriod(QString value)
{
    setts.setValue("categoryPeriod", value);
    emit categoryPeriodChanged();
}
QString Options::getCategoryPeriod()
{
    return setts.value("categoryPeriod", "Days").toString();
}

void Options::setCategoriesStat(int value)
{
    setts.setValue("categoriesStat", value);
    emit categoriesStatChanged();
}
int Options::getCategoriesStat()
{
    return setts.value("categoriesStat", 8).toInt();
}

void Options::setLanguage(QString value)
{
    setts.setValue("language", value);
    emit languageChanged();
}
QString Options::getLanguage()
{
    return setts.value("language", "en").toString();
}

void Options::setLanguageIndex(int value)
{
    setts.setValue("languageIndex", value);
    emit languageIndexChanged();
}
int Options::getLanguageIndex()
{
    return setts.value("languageIndex", 0).toInt();
}

void Options::setCurrency(QString value)
{
    setts.setValue("currency", value);
    emit currencyChanged();
}
QString Options::getCurrency()
{
    return setts.value("currency", "US$").toString();
}

void Options::setCurrencyBefore(bool value)
{
    setts.setValue("currencyBefore", value);
    emit currencyBeforeChanged();
}
bool Options::getCurrencyBefore()
{
    return setts.value("currencyBefore", true).toBool();
}

QString Options::returnDate(QString dateString, int daysAdd, QString format)
{
    QDate date = QDate::fromString(dateString, "yyyy/MM/dd");
    date = date.addDays(daysAdd);
    return date.toString(format);
}

QString Options::returnDateMonths(QString dateString, int monthsAdd, QString format)
{
    QDate date = QDate::fromString(dateString, "yyyy/MM/dd");
    date = date.addMonths(monthsAdd);
    return date.toString(format);
}

void Options::execCommand(QString command)
{
    QProcess process;
    process.start(command);
}
