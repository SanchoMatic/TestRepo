-- チャーレッド、ブラックロードの王 (Char-Red, King of the Blacklords)
local s, id = GetID()
function s.initial_effect(c)
    -- Synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0x2226), 1, 1, aux.FilterBoolFunction(Card.IsCode, 40600604), 1, 1)
    c:EnableReviveLimit()
    
    -- You can only control 1 "Char-Red, King of the Blacklords"
    c:SetUniqueOnField(1, 0, id)

    -- "Blacklord" monsters you control are unaffected by opponent's monster effects
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(s.effctarget)
    e1:SetValue(s.effcon)
    c:RegisterEffect(e1)
    
    -- Monsters your opponent controls lose ATK for each Fiend monster in the GYs
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    
    -- Special Summon 1 "Blacklord" monster from GY, then destroy 1 card on the field
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- Trigger effect at the end of the Damage Step
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

function s.effctarget(e, c)
    return c:IsSetCard(0x2226)
end

function s.effcon(e, te)
    return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(Card.IsRace, e:GetHandlerPlayer(), LOCATION_GRAVE, LOCATION_GRAVE, nil, RACE_FIEND) * -200
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return ep ~= tp
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x2226) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local dg = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
        if #dg > 0 then
            Duel.Destroy(dg, REASON_EFFECT)
        end
    end
end