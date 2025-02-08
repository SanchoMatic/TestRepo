-- Shadow Magician Girl
local s,id=GetID(11654940)
-- List the names of referenced cards
s.listed_names={CARD_DARK_MAGICIAN, 38033121}  -- Added "Dark Magician Girl" for reference

function s.initial_effect(c)
    -- Synchro Summon
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_SPELLCASTER),1,99)
    c:EnableReviveLimit()

    -- Change name to "Dark Magician Girl" on the field and in the GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e0:SetValue(38033121)  -- Card ID of "Dark Magician Girl"
    c:RegisterEffect(e0)

    -- Gain ATK/DEF for each "Dark Magician" on the field and in the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    -- Add 1 card that mentions "Dark Magician" or "Dark Magician Girl" if Special Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- Special Summon if "Dark Magician" you control leaves the field by any card effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)*600
end

function s.thfilter(c)
    return c:IsAbleToHand() and (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(38033121) or Card.ListsCode(c,CARD_DARK_MAGICIAN) or Card.ListsCode(c,38033121)) -- Check for "Dark Magician" or "Dark Magician Girl"
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tgfilter),tp,LOCATION_DECK,0,1,1,nil)
            if #g2>0 then
                Duel.SendtoGrave(g2,REASON_EFFECT)
            end
        end
    end
end

function s.tgfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsCode,1,nil,CARD_DARK_MAGICIAN) and eg:IsExists(Card.IsControler,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
