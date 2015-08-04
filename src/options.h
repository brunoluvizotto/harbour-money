#ifndef OPTIONS_H
#define OPTIONS_H

#include <QObject>
#include <QSettings>

namespace dbManager { namespace cascades { class Application; }}

class Options : public QObject
{
    Q_OBJECT

public:
    Options();

    QString getPaidPeriod();
    void setPaidPeriod(QString value);
    Q_PROPERTY(QString paidPeriod READ getPaidPeriod WRITE setPaidPeriod NOTIFY paidPeriodChanged)

    int getPaidPeriodIndex();
    void setPaidPeriodIndex(int value);
    Q_PROPERTY(int paidPeriodIndex READ getPaidPeriodIndex WRITE setPaidPeriodIndex NOTIFY paidPeriodIndexChanged)

    float getTarget();
    void setTarget(float value);
    Q_PROPERTY(float target READ getTarget WRITE setTarget NOTIFY targetChanged)

    int getDaysStat();
    void setDaysStat(int value);
    Q_PROPERTY(int daysStat READ getDaysStat WRITE setDaysStat NOTIFY daysStatChanged)

    int getMonthsStat();
    void setMonthsStat(int value);
    Q_PROPERTY(int monthsStat READ getMonthsStat WRITE setMonthsStat NOTIFY monthsStatChanged)

    int getLastCategoryStats();
    void setLastCategoryStats(int value);
    Q_PROPERTY(int lastCategoryStats READ getLastCategoryStats WRITE setLastCategoryStats NOTIFY lastCategoryStatsChanged)

    QString getCategoryPeriod();
    void setCategoryPeriod(QString value);
    Q_PROPERTY(QString categoryPeriod READ getCategoryPeriod WRITE setCategoryPeriod NOTIFY categoryPeriodChanged)

    int getCategoriesStat();
    void setCategoriesStat(int value);
    Q_PROPERTY(int categoriesStat READ getCategoriesStat WRITE setCategoriesStat NOTIFY categoriesStatChanged)

    QString getLanguage();
    void setLanguage(QString value);
    Q_PROPERTY(QString language READ getLanguage WRITE setLanguage NOTIFY languageChanged)

    int getLanguageIndex();
    void setLanguageIndex(int value);
    Q_PROPERTY(int languageIndex READ getLanguageIndex WRITE setLanguageIndex NOTIFY languageIndexChanged)

    QString getCurrency();
    void setCurrency(QString value);
    Q_PROPERTY(QString currency READ getCurrency WRITE setCurrency NOTIFY currencyChanged)

    bool getCurrencyBefore();
    void setCurrencyBefore(bool value);
    Q_PROPERTY(bool currencyBefore READ getCurrencyBefore WRITE setCurrencyBefore NOTIFY currencyBeforeChanged)

    Q_INVOKABLE QString returnDate(QString dateString, int daysAdd, QString format);
    Q_INVOKABLE QString returnDateMonths(QString dateString, int monthsAdd, QString format);
    Q_INVOKABLE void execCommand(QString command);

signals:
    void paidPeriodChanged();
    void paidPeriodIndexChanged();
    void targetChanged();
    void daysStatChanged();
    void monthsStatChanged();
    void lastCategoryStatsChanged();
    void categoryPeriodChanged();
    void categoriesStatChanged();
    void languageChanged();
    void languageIndexChanged();
    void currencyChanged();
    void currencyBeforeChanged();

private:
    QString paidPeriod;
    int paidPeriodIndex;
    float target;
    int daysStat;
    int monthsStat;
    int lastCategoryStats;
    QString categoryPeriod;
    int categoriesStat;
    QString language;
    int languageIndex;
    QString currency;
    bool currencyBefore;
    QSettings setts;
};

#endif // OPTIONS_H
