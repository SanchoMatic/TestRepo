-- ブラックロードのドラコ (Draco of the Blacklords)
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsSetCard, 0x2226), 1, 1)

    -- Banish Fiend/DARK Dragon and Special Summon Fiend Tuners
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Special Summon itself from GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

function s.spcon1(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.rmfilter(c)
    return (c:IsRace(RACE_FIEND) or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON))) and c:IsAbleToRemoveAsCost()
end

function s.spfilter(c, e, tp)
    return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcost1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.rmfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 3, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    e:SetLabel(#g)
end

function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, e:GetLabel(), tp, LOCATION_HAND + LOCATION_DECK)
end

function s.spop1(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil)
        and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        s.spcost1(e, tp, eg, ep, ev, re, r, rp, 1)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local spg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, e:GetLabel(), e:GetLabel(), nil, e, tp)
        if #spg > 0 then
            for tc in aux.Next(spg) do
                Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP)
            end
            Duel.SpecialSummonComplete()
            -- Restrict Special Summons for the rest of the turn
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetTargetRange(1, 0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(e1, tp)
        end
    end
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsType(TYPE_SYNCHRO)
end

function s.spcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.rmfilter2, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 2, e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.rmfilter2, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 2, 2, e:GetHandler())
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.rmfilter2(c)
    return not c:IsCode(id) and s.rmfilter(c)
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end